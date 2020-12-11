require 'csv'

class Admin::CommunityTransactionsController < Admin::AdminBaseController
  before_action :find_transaction, only: [:edit, :update, :charge_extra_fee, :refund_transaction, :charge_refund_fee, :destroy, :update_draft_order]
  before_action :set_service
  before_action :find_draft_transaction, only: [
    :add_listing_to_draft_order,
    :add_discount_to_draft_order,
    :update_draft_order_items,
    :update_draft_order_custom_items,
    :remove_draft_order_items,
    :remove_draft_order_custom_items,
    :add_shipping_fee_to_draft_order,
    :remove_draft_order_discount,
    :create_new_custom_item,
    :calculate_taxes
  ]

  def new
    @transaction = Transaction.create(transaction_type: 1)
  end

  def create
  end

  def update_draft_order
    person = Person.find_by(id: params[:draft_order_person_id])
    draft_order_params = {
      instructions_from_seller: params[:draft_order_note], starter: person
    }
    if params[:draft_order_status].present?
      draft_order_params = draft_order_params.merge(current_state: params[:draft_order_status])
    end
    @order.update(draft_order_params)
    flash[:notice] = 'Create draft order successfully!'
    redirect_to admin_community_draft_orders_path
  end

  def show
  end

  def index
    @selected_left_navi_link = "transactions"
    @transactions_presenter = AdminTransactionsPresenter.new(@current_community, params, request.format)
    if params[:transaction_type] && params[:transaction_type] == "abandoned_order"
      @selected_left_navi_link = "abandoned_orders"
      @transaction_type = 'abandoned_order'
      @transactions = @transactions_presenter.transactions.abandoned_order
    else
      @selected_left_navi_link = "transactions"
      @transaction_type = 'completed_order'
      @transactions = @transactions_presenter.transactions.complete
    end

    case params[:sort]
    when 'total'
      @transactions = @transactions.includes(:stripe_payments).order("stripe_payments.sum_cents #{params[:direction]}")
    when 'quantity'
      @transactions = @transactions.joins(:transaction_items).order("transaction_items.quantity #{params[:direction]}")
    else
      @transactions = @transactions.order("#{params[:sort]} #{params[:direction]}").order(order_number: :desc)
    end

    @transactions = @transactions.paginate(page: params[:page])
    respond_to do |format|
      format.html
      format.csv do
        marketplace_name = if @current_community.use_domain
          @current_community.domain
        else
          @current_community.ident
        end

        self.response.headers["Content-Type"] ||= 'text/csv'
        self.response.headers["Content-Disposition"] = "attachment; filename=#{marketplace_name}-transactions-#{Date.today}.csv"
        self.response.headers["Content-Transfer-Encoding"] = "binary"
        self.response.headers["Last-Modified"] = Time.now.ctime.to_s

        self.response_body = Enumerator.new do |yielder|
          ExportCompletedTransactionsJob.generate_csv_for(yielder, @transactions_presenter.transactions)
        end
      end
    end
  end

  def export
    @export_result = ExportTaskResult.create
    Delayed::Job.enqueue(ExportCompletedTransactionsJob.new(@current_user.id, @current_community.id, @export_result.id))
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def export_status
    export_result = ExportTaskResult.where(:token => params[:token]).first
    if export_result
      file_url = export_result.file.present? ? export_result.file.expiring_url(ExportTaskResult::AWS_S3_URL_EXPIRES_SECONDS) : nil
      render json: {token: export_result.token, status: export_result.status, url: file_url}
    else
      render json: {status: 'error'}
    end
  end

  def edit
    if @order.shipping_address
      @tax = Tax.find_by(province: @order.shipping_address.state_or_province)
    else
      @tax = Tax.first
    end
    get_amount_available
    calculate_money_service(@order)
  end

  def update
    calculate_money_service(@order)
    @order.update!(transaction_params)
    if params[:sent_tracking_number_to_customer] == 'on'
      SendgridMailer.new(@order, @current_community, @current_user).send_order_fulfilled_mail
    end
    flash[:notice] = "Update successfully!"
    redirect_to edit_admin_community_transaction_path(@current_community, @order)
  end

  def charge_extra_fee
    result = stripe_api.charge_extra_fee(stripe_payment_params)
    if result[:success]
      redirect_to edit_admin_community_transaction_path(@current_community, @order)
    else
      flash[:error] = result[:error]
      redirect_to edit_admin_community_transaction_path(@current_community, @order)
    end
    # TODO: sent invoice to user
  end

  def refund_transaction
    get_amount_available
  end

  def get_amount_available
    Stripe.api_key = APP_CONFIG.stripe_api_secret_key
    if @order.stripe_payments.standard.any?
      payment_intent = Stripe::PaymentIntent.retrieve(@order.stripe_payments.standard.last.stripe_payment_intent_id)
      charge_data = payment_intent.charges.data[0]
      charge_id = charge_data.id
      @amount_available = charge_data.amount - charge_data.amount_refunded
    else
      @amount_available = 0
    end
  end

  def charge_refund_fee
    result = stripe_api.charge_refund_fee(params)
    if result[:success]
      flash[:notice] =  "Successfully!"
      redirect_to edit_admin_community_transaction_path(@current_community, @order)
    else
      flash[:error] = result[:error]
      redirect_to refund_transaction_admin_community_transaction_path(@current_community, @order)
    end
  end

  def destroy
    result = stripe_api.cancel_an_order(params)
    if result[:success]
      flash[:notice] =  "Successfully!"
    else
      flash[:error] = result[:error]
    end
    redirect_to edit_admin_community_transaction_path(@current_community, @order)
  end

  def add_listing_to_draft_order
    @listings = @service.public_list.where(id: params[:ids])
    @listings.each do |listing|
      @transaction.create_transaction_item(listing)
    end
    calculate_money_service(@transaction).update_tax_cents_for_craft_order
    respond_to do |format|
      format.js { render layout: false }
      format.json { render json: listings, each_serializer: ListingSerializer }
    end
  end

  def add_discount_to_draft_order
    if params[:discount_type] == "percent"
      custom_params = {
        discount_percent: params[:discount_value].to_i,
        discount_value: 0
      }
    else
      custom_params = {
        discount_value: params[:discount_value].to_i * 100,
        discount_percent: 0
      }
    end
    custom_params = custom_params.merge({
      name: 'discount_code',
      price_cents: params[:price].to_i * 100,
      note: params[:reason],
      custom_item_type: 1,
    })

    if @transaction.draft_order_discount_code
      @transaction.draft_order_discount_code.update(custom_params)
    else
      @transaction.custom_items.create(custom_params)
    end
    calculate_money_service(@transaction).update_tax_cents_for_craft_order
    respond_to do |format|
      format.js { render layout: false }
      format.json { render json: listings, each_serializer: ListingSerializer }
    end
  end

  def update_draft_order_items
    items = @transaction.transaction_items.find(params[:transaction_item_id])
    items.update(price_cents: to_price_cents(params[:price].to_i), quantity: params[:quantity])
    calculate_money_service(@transaction).update_tax_cents_for_craft_order
    respond_to do |format|
      format.js { render layout: false }
      format.json { render json: listings, each_serializer: ListingSerializer }
    end
  end

  def update_draft_order_custom_items
    items = @transaction.custom_items.find(params[:custom_item_id])
    items.update(price_cents: to_price_cents(params[:price].to_i), quantity: params[:quantity])
    calculate_money_service(@transaction).update_tax_cents_for_craft_order
    respond_to do |format|
      format.js { render layout: false }
      format.json { render json: listings, each_serializer: ListingSerializer }
    end
  end

  def remove_draft_order_items
    items = @transaction.transaction_items.find(params[:transaction_item_id]).delete
    calculate_money_service(@transaction).update_tax_cents_for_craft_order
    respond_to do |format|
      format.js { render layout: false }
      format.json { render json: listings, each_serializer: ListingSerializer }
    end
  end

  def remove_draft_order_custom_items
    items = @transaction.custom_items.find(params[:custom_item_id]).delete
    calculate_money_service(@transaction).update_tax_cents_for_craft_order
    respond_to do |format|
      format.js { render layout: false }
      format.json { render json: listings, each_serializer: ListingSerializer }
    end
  end

  def add_shipping_fee_to_draft_order
    if params[:free_shipping] == 'true'
      @transaction.draft_order_shipping_fee.delete if @transaction.draft_order_shipping_fee
    else
      shipping_fee = params[:shipping_price].to_i
      custom_params = {
        name: params[:custom_rate_name],
        price_cents: shipping_fee * 100,
        custom_item_type: 2,
      }
      if @transaction.draft_order_shipping_fee
        @transaction.draft_order_shipping_fee.update(custom_params)
      else
        @transaction.custom_items.create(custom_params)
      end
    end
    calculate_money_service(@transaction).update_tax_cents_for_craft_order
    respond_to do |format|
      format.js { render layout: false }
      format.json { render json: listings, each_serializer: ListingSerializer }
    end
  end

  def remove_draft_order_discount
    @transaction.draft_order_discount_code.delete
    calculate_money_service(@transaction).update_tax_cents_for_craft_order
    respond_to do |format|
      format.js { render layout: false }
      format.json { render json: listings, each_serializer: ListingSerializer }
    end
  end

  def create_new_custom_item
    @transaction.custom_items.create(
      name: params[:title],
      price_cents: params[:price].to_i * 100,
      quantity: params[:quantity],
    )
    calculate_money_service(@transaction).update_tax_cents_for_craft_order
    respond_to do |format|
      format.js { render layout: false }
      format.json { render json: listing, each_serializer: ListingSerializer }
    end
  end

  def calculate_taxes
    if params[:will_charge_taxes] == 'true'
      tax_percent = params[:tax_percent].to_i
      tax_cents = calculate_money_service(@transaction).get_tax_fee_for_draft_order(tax_percent)
      @transaction.update(
        tax_percent: tax_percent,
        tax_cents: tax_cents
      )
    else
      @transaction.update(
        tax_percent: 0,
        tax_cents: 0
      )
    end
    respond_to do |format|
      format.js { render layout: false }
      format.json { render json: listing, each_serializer: ListingSerializer }
    end
  end

  private
  def find_draft_transaction
    @transaction = Transaction.find(params[:transaction_id])
  end

  def calculate_money_service(transaction)
    @calculate_money = TransactionMoneyCalculation.new(transaction, session, @current_user)
  end

  def transaction_params
    params
    .require(:transaction)
    .permit(
      :tracking_number,
      :shipping_carrier,
      :instructions_from_seller
    )
  end

  def stripe_payment_params
    params
    .require(:stripe_payment)
    .permit(
      :fee_cents,
      :note
    )
  end

  def find_transaction
    @order = Transaction.find(params[:id])
  end

  def calculate_money_service(order=nil)
    transaction = order || @order
    @calculate_money = TransactionMoneyCalculation.new(transaction, session, @current_user)
  end

  def stripe_api
    StripeService::API::Api.payments_v2.new(@order, session, @current_user)
  end

  def set_service
    @service = Admin::ListingsService.new(
      community: @current_community,
      params: params)
    @presenter = Listing::ListPresenter.new(@current_community, @current_user, params, true)
  end
end

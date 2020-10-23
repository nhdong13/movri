class Admin::CommunityListingsController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service

  layout false, only: [:edit, :update]
  respond_to :html, :js

  def index
    listings = @service.public_list
    respond_to do |format|
      format.html
      format.json { render json: listings, each_serializer: ListingSerializer }
    end
  end

  def update
    @service.update
  end

  def approve
    @service.approve
    redirect_to listing_path(@service.listing)
  end

  def reject
    @service.reject
    redirect_to listing_path(@service.listing)
  end

  def export
    @export_result = ExportTaskResult.create
    Delayed::Job.enqueue(ExportListingsJob.new(@current_user.id, @current_community.id, @export_result.id))
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

  def add_listing_to_draft_order
    @transaction = Transaction.find(params[:transaction_id])
    @listings = @service.public_list.where(id: params[:ids])
    @listings.each do |listing|
      @transaction.create_transaction_item(listing)
    end
    respond_to do |format|
      format.js { render layout: false }
      format.json { render json: listings, each_serializer: ListingSerializer }
    end
  end

  def add_discount_to_draft_order
    @transaction = Transaction.find(params[:transaction_id])
    discount_percent = params[:discount_percent].to_i
    custom_params = {
      name: 'discount_code',
      price_cents: params[:price].to_i * 100,
      note: params[:reason],
      discount_percent: discount_percent,
      custom_item_type: 1,
    }
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
    @transaction = Transaction.find(params[:transaction_id])
    respond_to do |format|
      format.js { render layout: false }
      format.json { render json: listings, each_serializer: ListingSerializer }
    end
  end

  def add_shipping_fee_to_draft_order
    @transaction = Transaction.find(params[:transaction_id])
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
    @transaction = Transaction.find(params[:transaction_id])
    @transaction.draft_order_discount_code.delete
    calculate_money_service(@transaction).update_tax_cents_for_craft_order
    respond_to do |format|
      format.js { render layout: false }
      format.json { render json: listings, each_serializer: ListingSerializer }
    end
  end

  def create_new_custom_item
    @transaction = Transaction.find(params[:transaction_id])
    @transaction.custom_items.create(
      name: params[:title],
      price_cents: params[:price].to_i * 100,
      quantity: params[:quantity],
    )
    respond_to do |format|
      format.js { render layout: false }
      format.json { render json: listing, each_serializer: ListingSerializer }
    end
  end

  def calculate_taxes
    @transaction = Transaction.find(params[:transaction_id])
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

  def set_selected_left_navi_link
    @selected_left_navi_link = 'listings'
  end

  def calculate_money_service(transaction)
    @calculate_money = TransactionMoneyCalculation.new(transaction, session, @current_user)
  end

  def set_service
    @service = Admin::ListingsService.new(
      community: @current_community,
      params: params)
    @presenter = Listing::ListPresenter.new(@current_community, @current_user, params, true)
  end
end

class TransactionAddressesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create, :create_billing_address, :update]
  before_action :find_transaction
  before_action :find_transaction_address

  def create
    @transaction_address = TransactionAddress.create(transaction_address_params)
    if @transaction_address
      @transaction.update(shipping_address_id: @transaction_address.id) if @transaction
      if @current_user
        @transaction_address.update(person_id: @current_user.id)
        @current_user.update(default_shipping_address: @transaction_address.id) if @transaction_address.shipping_address? && !@current_user.shipping_address
        @current_user.update(default_billing_address: @transaction_address.id) if @transaction_address.billing_address? && !@current_user.billing_address
      end
    end
    if params[:transaction_id]
      return redirect_to shipment_transaction_path(@transaction.uuid_object)
    else
      return redirect_to person_path(@current_user, view: "info")
    end
  end

  def new
    @transaction_address = TransactionAddress.new
    @is_shipping_address = params[:address_type] == 'shipping_address'
    @address_type = params[:address_type].titleize
  end

  def edit
    @is_shipping_address = @transaction_address.shipping_address?
    @address_type = @transaction_address.address_type.titleize
  end

  def pay_order
    session[:billing_address] = transaction_address_params if params[:remember_me] == "true"
    if params[:address_type] == "billing_address"
      result = stripe_api.processing_billing_address_and_payment_intent(params, transaction_address_params)
      return render json: {errors: result[:error]} unless (result[:success])
    else
      #update billing address is the same as shipping address
      @transaction.update(billing_address_id: @transaction.shipping_address.id)
      result = stripe_api.create_payment_intent(params[:stripe_payment_method_id])
      return render json: {errors: result[:error]} unless (result[:success])
    end

    # refesh session
    session[:cart] = {}
    session[:promo_code] = {}
    # reset session coverage
    session[:coverage] = {}
    session[:transaction] = {}
    @calculate_money = TransactionMoneyCalculation.new(@transaction, session, @current_user)
    data_transaction = {
      transaction_id: @transaction.id,
      value: MoneyViewUtils.to_CAD(@transaction.stripe_payments.standard.last.sum_cents),
      currency: "USD",
      tax: MoneyViewUtils.to_CAD(@calculate_money.get_tax_fee),
      items:
        @transaction.transaction_items.map do |item|
          listing = item.listing
          if listing
            {
              id: listing.id,
              name: listing.title,
              quantity: item.quantity,
              price: MoneyViewUtils.to_CAD(item.price_cents)
            }
          end
        end
      }
    respond_to do |format|
      format.html
      format.json {
        render json: {
          redirect_url: thank_you_transaction_path(@transaction.uuid_object),
          data_transaction: data_transaction,
          klaviyo_placed_order_data: klaviyo_service(@transaction).get_data_for_placed_order
        }
      }
    end
  end

  def set_default_address
    if @transaction_address.billing_address?
      @current_user.update(default_billing_address:  @transaction_address.id)
    else
      @current_user.update(default_shipping_address:  @transaction_address.id)
    end
    respond_to do |format|
      format.html
      format.json { render json: { success: true } }
    end
  end

  def update
    success = @transaction_address.update(transaction_address_params)
    if success
      if params[:transaction_id]
        return redirect_to shipment_transaction_path(@transaction.uuid_object)
      else
        return redirect_to person_path(@current_user, view: "info")
      end
    else
      flash[:error] = @transaction_address.errors.full_messages.first
      if params[:transaction_id]
        return redirect_to checkout_transaction_path(@transaction.uuid_object)
      else
        return redirect_to edit_transaction_address_path(@transaction_address)
      end
    end
  end

  def change_shipping_method_shipment_process
    @state = params[:state]
    respond_to do |format|
      format.html
      format.js { render :layout => false}
    end
  end

  def destroy
    if @current_user
      if @transaction_address.shipping_address? && @current_user.shipping_address == @transaction_address
        new_address = @current_user.shipping_addresses.where.not(id: @transaction_address.id).last
        @current_user.update(default_shipping_address: new_address.id) if new_address
      elsif @transaction_address.billing_address? && @current_user.billing_address == @transaction_address
        new_address = @current_user.billing_addresses.where.not(id: @transaction_address.id).last
        @current_user.update(default_billing_address: new_address.id) if new_address
      end
    end
    @transaction_address.soft_delete
    redirect_to person_path(@current_user, view: "info")
  end

  private
  def find_transaction_address
    @transaction_address = TransactionAddress.find_by(id: params[:id])
  end

  def find_transaction
    @transaction = Transaction.find_by(id: params[:transaction_id])
  end

  def transaction_address_params
    params
    .require(:transaction_address)
    .permit(
      :address_type,
      :email,
      :first_name,
      :last_name,
      :company,
      :street1,
      :apartment,
      :city,
      :state_or_province,
      :postal_code,
      :phone
    )
  end

  def stripe_api
    StripeService::API::Api.payments_v2.new(@transaction, session, @current_user)
  end

  def calculate_money_service(transaction=nil)
    transaction = transaction || @transaction
    @calculate_money = TransactionMoneyCalculation.new(transaction, session, @current_user)
  end

  def klaviyo_service(transaction=nil)
    transaction = transaction || @transaction
    @klaviyo_service = KlaviyoService.new(transaction, session, @current_user)
  end
end

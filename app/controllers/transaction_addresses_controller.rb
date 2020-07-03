class TransactionAddressesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create, :create_billing_address, :update]
  before_action :find_transaction
  before_action :find_transaction_address

  def create
    # @transaction_address = @transaction.transaction_addresses.create(transaction_address_params)
    @transaction_address = TransactionAddress.create(transaction_address_params)
    if @current_user
      @transaction_address.update(person_id: @current_user.id)
      @current_user.update(default_shipping_address: @transaction_address.id) if @transaction_address.shipping_address? && @current_user.default_shipping_address.nil?
      @current_user.update(default_billing_address: @transaction_address.id) if @transaction_address.billing_address? && @current_user.default_billing_address.nil?
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
  end

  def edit
  end

  def create_billing_address
    session[:billing_address] = transaction_address_params if params[:remember_me] == "true"

    if params[:address_type] == "billing_address"
      result = stripe_api.create_billing_address_and_payment_intent(params, transaction_address_params)
      return render json: {errors: result[:error]} unless (result[:success])
    else
      result = stripe_api.create_payment_intent(params[:stripe_payment_method_id])
      return render json: {errors: result[:error]} unless (result[:success])
    end

    # refesh session
    session[:cart] = {}
    respond_to do |format|
      format.html
      format.json { render json: { redirect_url: thank_you_transaction_path(@transaction.uuid_object) } }
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
    @transaction_address.update(person_id: @current_user.id)  if @current_user
    if success
      redirect_to shipment_transaction_path(@transaction.uuid_object)
    else
      flash[:error] = @transaction_address.errors.full_messages.first
      redirect_to checkout_transaction_path(@transaction.uuid_object)
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
    StripeService::API::Api.payments_v2.new(@transaction, session)
  end
end

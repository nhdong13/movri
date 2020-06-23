class TransactionAddressesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :find_transaction
  before_action :find_transaction_address

  def create
    @transaction_address = @transaction.transaction_addresses.create!(transaction_address_params)
    byebug
    if @transaction_address.billing_address? && params[:stripe_payment_method_id]
      stripe_api.create_payment_intent(params[:stripe_payment_method_id])
    end
    # redirect_to shipment_transaction_path(@transaction.uuid_object)
    respond_to do |format|
      format.html { redirect_to shipment_transaction_path(@transaction.uuid_object) }
      format.json { render json: { redirect_url: shipment_transaction_path(@transaction.uuid_object) } }
    end
  end

  def update
    success = @transaction_address.update(transaction_address_params)
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

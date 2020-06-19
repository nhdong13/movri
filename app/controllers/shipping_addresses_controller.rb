class ShippingAddressesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :find_transaction
  before_action :find_shipping_address

  def create
    @shipping_address = @transaction.create_shipping_address(shipping_address_params)
    redirect_to shipment_transaction_path(@transaction.uuid_object)
  end

  def update
    success = @shipping_address.update(shipping_address_params)
    if success
      redirect_to shipment_transaction_path(@transaction.uuid_object)
    else
      flash[:error] = @shipping_address.errors.full_messages.first
      redirect_to checkout_transaction_path(@transaction.uuid_object)
      # redirect_to shipment_transaction_path(@transaction.uuid_object)
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
  def find_shipping_address
    @shipping_address = ShippingAddress.find_by(id: params[:id])
  end

  def find_transaction
    @transaction = Transaction.find_by(id: params[:transaction_id])
  end

  def shipping_address_params
    params
    .require(:shipping_address)
    .permit(
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
end

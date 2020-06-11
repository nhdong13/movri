class ShippingAddressesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :find_transaction
  def create
    @shipping_address = @transaction.create_shipping_address(shipping_address_params)
  end

  def change_state_shipping_form
    @state = params[:state]
    respond_to do |format|
      format.html
      format.js { render :layout => false}
    end
  end

  private
  def find_transaction
    @transaction = Transaction.find_by(id: params[:transaction_id])
  end

  def shipping_address_params
    params
    .require(:shipping_address)
    .permit(
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

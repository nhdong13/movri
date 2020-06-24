class ShippersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :find_transaction

  def update
    shipper = @transaction.shipper.update(get_shipper_params)
    if shipper
      redirect_to payment_transaction_path(@transaction.uuid_object)
    else
      flash[:error] = 'Something went wrong!'
      redirect_to shipment_transaction_path(@transaction.uuid_object)
    end
  end

  private
  def find_transaction
    @transaction = Transaction.find_by(id: params[:transaction_id])
  end

  def get_shipper_params
    shipping_selection = session[:shipping][:fedex].select{ |s| s["service_type"] == params[:shipper][:service_type] }
    return unless shipping_selection.any?
    shipping_selection = shipping_selection.first
    shipper_params = {
      service_type: shipping_selection['service_type'],
      service_name: shipping_selection['service_name'],
      amount: shipping_selection['total_charge']['amount'],
      currency: shipping_selection['total_charge']['currency'],
    }
  end
end

class Admin::ShippingAdditionalFeesController < Admin::AdminBaseController
  before_action :shipping_additional_fee

  def edit
    @shipping_additional_fee = @shipping_additional_fee || ShippingAdditionalFee.new
  end

  def create
    @shipping_additional_fee = ShippingAdditionalFee.create(shipping_additional_fee_param)
    redirect_to edit_admin_shipping_additional_fee_path
  end

  def update
    @shipping_additional_fee.update(shipping_additional_fee_param)
    redirect_to edit_admin_shipping_additional_fee_path

  end

  private

  def shipping_additional_fee_param
    params
      .require(:shipping_additional_fee)
      .permit(
        :handling,
        :insurance
      )
  end

  def shipping_additional_fee
    @shipping_additional_fee = ShippingAdditionalFee.last
  end
end

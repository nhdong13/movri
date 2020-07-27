class Admin::CheckoutSettingsController < Admin::AdminBaseController
  def show
    @checkout_setting = CheckoutSetting.last
  end
end

class Admin::CheckoutSettingsController < Admin::AdminBaseController
  before_action :get_checkout_setting
  def show
    @checkout_setting = CheckoutSetting.last
  end

  def update
    @checkout_setting = @checkout_setting.update checkout_setting_params
    if @checkout_setting
      flash[:notice] = 'Update checkout setting successfully!'
    else
      flash[:error] = 'Update checkout setting failed. Please try again!'
    end
    redirect_to admin_checkout_setting_path
  end

  private
  def get_checkout_setting
    @checkout_setting = CheckoutSetting.last
  end

  def checkout_setting_params
    params
      .require(:checkout_setting)
      .permit(
        :account_permission,
        :order_notes,
        :contact,
        :add_info_after_complete_order,
        :can_download_app,
        :full_name_option,
        :company_name_option,
        :address_2_option,
        :shipping_address_phone_option,
        :use_shipping_address_as_billing_address,
        :address_autocompletion,
        :auto_achive_the_order,
        :show_sign_up_at_checkout,
        :preselect_sign_up,
        :auto_send_abandoned_mails,
        :abandoned_emails_will_send_to_option,
        :time_abandoned_emails_will_send_option,
        :logo_position,
        :logo_size,
        :logo
      )
  end
end

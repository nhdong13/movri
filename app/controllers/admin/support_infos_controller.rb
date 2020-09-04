class Admin::SupportInfosController < Admin::AdminBaseController
  before_action :find_support_info

  def edit
  end

  def create
    @support_info = SupportInfo.create(support_info_param)
    redirect_to edit_admin_support_info_path
  end

  def update
    @support_info.update(support_info_param)
    redirect_to edit_admin_support_info_path
  end

  private
  def support_info_param
    params
      .require(:support_info)
      .permit(
        :heading,
        :sub_heading,
        :phone,
        :phone_link,
        :email,
        :email_link,
        :image
      )
  end

  def find_support_info
    @support_info = SupportInfo.last || SupportInfo.new
  end
end

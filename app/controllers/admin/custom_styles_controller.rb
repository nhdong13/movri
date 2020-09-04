class Admin::CustomStylesController < Admin::AdminBaseController
  before_action :find_custom_style
  def edit
    @custom_style = @custom_style || CustomStyle.new
  end

  def create
    @custom_style = CustomStyle.create(custom_style_param)
    redirect_to edit_admin_custom_style_path
  end

  def update
    @custom_style.update(custom_style_param)
    redirect_to edit_admin_custom_style_path
  end

  private
  def custom_style_param
    params
      .require(:custom_style)
      .permit(
        :style_string
      )
  end

  def find_custom_style
    @custom_style = CustomStyle.last
  end
end

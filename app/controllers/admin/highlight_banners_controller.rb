class Admin::HighlightBannersController < Admin::AdminBaseController
  before_action :set_highlight_banner, only: [:update]

  def update
    if @highlight_banner.update_attributes(highlight_banner_params)
      render json: {success: true, highlight_banner: @highlight_banner.as_json}
    else
      render json: {success: true, messages: @highlight_banner.errors.full_messages}
    end
  end

  private
  def set_highlight_banner
    @highlight_banner = HighlightBanner.find params[:id]
  end
  
  def highlight_banner_params
    params.require(:highlight_banner).permit(:enabled, :text_color, :background_color)
  end
end
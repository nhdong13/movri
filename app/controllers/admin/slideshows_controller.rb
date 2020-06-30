class Admin::SlideshowsController < Admin::AdminBaseController
  before_action :set_slideshow, only: [:update]

  def update
    if @slideshow.update_attributes(slideshow_params)
      render json: { success: true, slideshow: @slideshow.as_json }
    else
      render json: { success: false, messages: @slideshow.errors.full_messages}
    end
  end

  private
  def set_slideshow
    @slideshow = Slideshow.find params[:id]
  end

  def slideshow_params
    params.require(:slideshow).permit(:enabled, :auto_play, :slide_duration)
  end
end
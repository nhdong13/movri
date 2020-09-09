class Admin::SlideItemsController < Admin::AdminBaseController
  before_action :set_slideshow, only: [:new, :create, :update, :image_upload, :destroy]
  before_action :set_item, only: [:update, :destroy, :image_upload]

  def new
    slide_item = @slideshow.slide_items.new
    render json: { success: true, slide_item: slide_item.as_json}
  end

  def update
    if @slide_item.update_attributes(slide_item_params)
      render json: { success: true, slide_item: @slide_item.as_json }
    else
      render json: { success: false, messages: @slide_item_params.errors.full_messages}
    end
  end

  def create
    @slide_item = @slideshow.slide_items.new(slide_item_params)
    if @slide_item.save
      render json: { success: true, slide_item: @slide_item.as_json }
    else
      render json: { success: false, messages: @slide_item_params.errors.full_messages}
    end
  end

  def destroy
    if @slide_item.destroy
      render json: { success: true, object: @slideshow.reload.as_json }
    else
      render json: { success: false, messages: @slide_item_params.errors.full_messages}
    end
  end

  def image_upload
    @slide_item.update(image: params[:image])
  end

  private
  def set_slideshow
    @slideshow = Slideshow.find params[:slideshow_id]
  end

  def set_item 
    @slide_item = SlideItem.find params[:id]
  end

  def slide_item_params
    params.require(:slide_item).permit(:heading, :sub_heading, :background_link, :text_alignment, :button_label, :button_link, :text_color, :image)
  end
end
class Admin::BannerItemsController < Admin::AdminBaseController
  before_action :set_highlight_banner, only: [:create, :new, :update]
  before_action :set_banner_item, only: [:update, :destroy]
  
  def new
    banner_item = @highlight_banner.banner_items.new
    render json: { success: true, banner_item: banner_item.as_json }
  end

  def create
    @banner_item = @highlight_banner.banner_items.new(banner_item_params)
    if @banner_item.save
      render json: { success: true, banner_item: @banner_item.as_json }
    else
      render json: { success: false, banner_item: @banner_item.errors.full_messages }
    end
  end

  def update
    if @banner_item.update_attributes(banner_item_params)
      render json: { success: true, banner_item: @banner_item.as_json }
    else
      render json: { success: false, banner_item: @banner_item.errors.full_messages }
    end
  end

  def destroy
    if @banner_item.destroy
      render json: { success: true }
    else
      render json: { success: false, banner_item: @banner_item.errors.full_messages }
    end
  end

  private
  def set_highlight_banner
    @highlight_banner = HighlightBanner.find params[:highlight_banner_id]
  end

  def set_banner_item
    @banner_item = BannerItem.find params[:id]
  end

  def banner_item_params
    params.require(:banner_item).permit(:image, :heading, :sub_heading, :text, :link)
  end
end
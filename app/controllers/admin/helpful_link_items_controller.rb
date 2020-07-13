class Admin::HelpfulLinkItemsController < Admin::AdminBaseController
  before_action :set_helpful_link
  before_action :set_helpful_link_item, only: [:update, :destroy]

  def create
    result = admin_section_item_service.create('helpful_link_items', helpful_link_item_params)
    render json: result
  end

  def update
    result = admin_section_item_service.update(@helpful_link_item, helpful_link_item_params)
    render json: result
  end

  def destroy 
    result = admin_section_item_service.destroy(@helpful_link_item)
    render json: result
  end

  private

  def set_helpful_link
    @helpful_link = HelpfulLink.find params[:helpful_link_id]
  end

  def set_helpful_link_item
    @helpful_link_item = HelpfulLinkItem.find params[:id]
  end

  def helpful_link_item_params
    params.require(:helpful_link_item)
      .permit(:heading, :text, :heading_color, :text_color, :enabled, :content_type, footer_links_attributes: [:id, :sub_heading, :link], footer_social_accounts_attributes: [:id, :alt_text, :link, :image])
  end

  def admin_section_item_service
    @admin_section_item_service ||= Admin::SectionItemService.new(@helpful_link)
  end
end
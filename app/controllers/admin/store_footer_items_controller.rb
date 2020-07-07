class Admin::StoreFooterItemsController < Admin::AdminBaseController
  before_action :set_store_footer, only: [:create]
  before_action :set_store_footer_item, only: [:update, :destroy]

  def create
    @store_footer_item = @store_footer.store_footer_items.new store_footer_item_params
    if @store_footer_item.save
      render_success
    else
      render_failure
    end
  end

  def update
    if @store_footer_item.update_attributes(store_footer_item_params)
      render_success
    else
      render_failure
    end
  end

  def destroy
    if @store_footer_item.destroy
      render json: {success: true}
    else
      render_failure
    end
  end

  private
  def set_store_footer
    @store_footer = StoreFooter.find params[:store_footer_id]
  end

  def set_store_footer_item
    @store_footer_item = StoreFooterItem.find params[:id]
  end

  def store_footer_item_params
    params.require(:store_footer_item)
      .permit(:heading, :sub_heading, :text, :link)
  end

  def render_success
    render json: { success: true, store_footer_item: @store_footer_item.as_json }
  end

  def render_failure
    render json: { success: false, messages: @store_footer_item.errors.full_messages }
  end
end
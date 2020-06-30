class Admin::StoreCategoryItemsController < Admin::AdminBaseController
  before_action :set_store_category
  before_action :set_store_category_item, only: [:update, :destroy]

  def new
    @store_category_item = @store_category.store_category_items.new
    render json: { success: true,  store_category_item: @store_category_item}
  end

  def create
    @store_category_item = @store_category.store_category_items.new(store_category_item_params)
    if @store_category_item.save
      render json: { success: true, store_category_item: 
      @store_category_item.as_json }
    else
      render json: { success: false, messages: @store_category_item.errors.full_messages }
    end
  end

  def update
    if @store_category_item.update_attributes(store_category_item_params)
      render json: { success: true, store_category_item: @store_category_item.as_json }
    else
      render json: { success: false, messages: @store_category_item.errors.full_messages }
    end
  end

  def destroy
    if @store_category_item.destroy
      render json: { success: true }
    else
      render json: { success: false, messages: @store_category_item.errors.full_messages }
    end
  end

  private
  def set_store_category
    @store_category = StoreCategory.find params[:store_category_id]
  end

  def set_store_category_item
    @store_category_item = StoreCategoryItem.find params[:id]
  end

  def store_category_item_params
    params.require(:store_category_item).permit(:category_id, :image)
  end
end
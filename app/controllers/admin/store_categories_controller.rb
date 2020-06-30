class Admin::StoreCategoriesController < Admin::AdminBaseController
  before_action :set_store_category, only: [:update]
  
  def create
    # @section = @online_store.section.new(name")
    @store_category  = StoreCategory.new(heading: store_category_params[:heading], online_store_id: @current_online_store.id )
    if @store_category.save
      @current_online_store.sections.create(
        name: 'StoreCategory',
        sectionable_id: @store_category.id,
        sectionable_type: 'StoreCategory'
      )
      render json: { success: true, store_category: @store_category.as_json }
    else
      render json: {success: false, messages: @store_category.errors.full_messages }
    end
  end

  def update
    if @store_category.update_attributes(store_category_params)
      render json: { success: true, store_category: @store_category.as_json }
    else
      render json: {success: false, messages: store_category.errors.full_messages }
    end
  end


  private
  def set_store_category
    @store_category = StoreCategory.find params[:id]
  end

  def store_category_params
    params.require(:store_category).permit(:heading)
  end
end
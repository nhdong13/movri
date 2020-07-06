class Admin::StoreFeaturedProductsController < Admin::AdminBaseController
  before_action :set_featured_list, only: [:update, :destroy]

  def create
    featured_product = StoreFeaturedProduct.new(heading: featured_product_params[:heading], button_text_color: featured_product_params[:button_text_color],online_store_id: @current_online_store.id )
    if featured_product.save
      featured_product.product_ids = featured_product_params[:product_ids]
      section = @current_online_store.sections.create(
        name: 'FeaturedList',
        sectionable_id: featured_product.id,
        sectionable_type: 'StoreFeaturedProduct'
      )
      render json: { success: true, section: section.as_json }
    else
      render json: { success: false, messages: featured_product.errors.full_messages }
    end
  end

  def update
    if @featured_list.update_attributes(featured_product_params)
      render json: { success: true, section: @featured_list.section.as_json }
    else
      render json: { success: false, messages: @featured_list.errors.full_messages }
    end
  end

  def destroy
    if @featured_list.destroy
      @featured_list.section.delete
      render json: {success: true}
    else
      render json: { success: false, messages: @featured_list.errors.full_messages }
    end
  end

  private

  def set_featured_list
    @featured_list = StoreFeaturedProduct.find params[:id]
  end

  def featured_product_params
    params.require(:store_featured_product).permit(:heading, :button_text_color, product_ids: [])
  end
end
class Admin::StoreGridsController < Admin::AdminBaseController
  before_action :set_store_grid, only: [:update, :destroy, :sort_items]

  def create
    store_grid = StoreGrid.new(store_grid_params)
    if store_grid.save
      section = @current_online_store.sections.create(
        name: 'StoreGrid',
        sectionable_id: store_grid.id,
        sectionable_type: 'StoreGrid'
      )
      render json: { success: true, section: section.as_json }
    else
      render json: { success: false, messages: store_grid.errors.full_messages }
    end
  end

  def update
    if @store_grid.update_attributes(store_grid_params)
      render json: { success: true, section: @store_grid.section.as_json }
    else
      render json: { success: false, messages: @store_grid.errors.full_messages }
    end
  end

  def destroy
    if @store_grid.destroy
      @store_grid.section.delete
      render json: { success: true }
    else
      render json: { success: false, messages: @store_grid.errors.full_messages }
    end
  end

  def sort_items
    params[:items].each do |item|
      @store_grid.store_grid_items.find(item[:id]).update(order_number: item[:order_number])
    end

    render json: { success: true, object: @store_grid.as_json }
  end

  private
  def store_grid_params
    params.require(:store_grid)
      .permit(:heading, :height, :text_alignment, :compress_block, :maintain_aspect_ratio)
  end

  def set_store_grid
    @store_grid = StoreGrid.find params[:id]
  end
end
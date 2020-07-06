class Admin::StoreGridItemsController < Admin::AdminBaseController
  before_action :set_store_grid, only: [:create]
  before_action :set_store_grid_item, only: [:update, :destroy]

  def create
    @store_grid_item = @store_grid.store_grid_items.new(store_grid_item_params)
    if @store_grid_item.save
      render_success
    else
      render_failure
    end
  end

  def update
    if @store_grid_item.update_attributes(store_grid_item_params)
      render_success
    else
      render_failure
    end
  end

  def destroy
    if @store_grid_item.destroy
      render json: { success: true }
    else
      render_failure
    end
  end

  private

  def set_store_grid
    @store_grid = StoreGrid.find params[:store_grid_id]
  end

  def set_store_grid_item
    @store_grid_item = StoreGridItem.find params[:id]
  end

  def store_grid_item_params
    params.require(:store_grid_item)
      .permit(
        :heading,
        :image,
        :text,
        :text_color,
        :button_text,
        :button_style,
        :width
      )
  end

  def render_success
    render json: { success: true, store_grid_item: @store_grid_item.as_json }
  end

  def render_failure
    render json: { success: false, messages: @store_grid_item.errors.full_messages }
  end
end
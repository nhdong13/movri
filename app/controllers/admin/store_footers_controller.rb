class Admin::StoreFootersController < Admin::AdminBaseController
  before_action :set_store_footer, only: [:update, :destroy]

  def create
    store_footer = StoreFooter.new(store_footer_params)
    if store_footer.save
      section = @current_online_store.sections.create(
        name: 'StoreFooter',
        sectionable_id: store_footer.id,
        sectionable_type: 'StoreFooter'
      )
      render json: { success: true, section: section.as_json }
    else
      render json: { success: false, messages: store_footer.errors.full_messages }
    end
  end

  def update
    if @store_footer.update_attributes(store_footer_params)
      render json: { success: true, section: @store_footer.section.as_json }
    else
      render json: { success: false, messages: @store_footer.errors.full_messages }
    end
  end

  def destroy
    if @store_footer.destroy
      @store_footer.section.destroy
      render json: { success: true }
    else
      render json: { success: false, messages: @store_footer.errors.full_messages }
    end
  end

  private

  def set_store_footer
    @store_footer = StoreFooter.find params[:id]
  end

  def store_footer_params
    params.require(:store_footer)
      .permit(:name, :enabled, :text_color, :background_color)
  end
end
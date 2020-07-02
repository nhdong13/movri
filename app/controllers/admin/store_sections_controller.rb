class Admin::StoreSectionsController < Admin::AdminBaseController
  skip_before_action :ensure_is_admin
  before_action :set_store, only: [:create]

  def create
    section =  @store.sections.new(name: params[:name])
    if section.save
      model = params[:name].constantize
      record = model.create!(online_store_id: @store.id)
      section.update_columns(sectionable_id: record.id, sectionable_type: record.class.name)
      render json: { success: true, item: section.as_json }
    else
      render json: { success: false, message: 'Cannot create this section' }
    end
  end


  private
  def set_store
    @store ||= OnlineStore.find(params[:online_store_id])
  end
end
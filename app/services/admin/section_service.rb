class Admin::SectionService
  attr_accessor :online_store

  def initialize(online_store)
    @online_store = online_store
  end

  def create(model, model_params)
    object = model.constantize.new(model_params)
    if object.save
      section = online_store.sections.create(
        name: model,
        sectionable_id: object.id,
        sectionable_type: model
      )

      return { success: true, section: section.as_json }
    else
      return  { success: false, messages: object.errors.full_messages }
    end
  end

  def update object, object_params
    if object.update_attributes(object_params)
      return { success: true, section: object.section.as_json }
    else
      return { success: false, messages: object.errors.full_messages }
    end
  end

  def destroy object
    if object.destroy
      object.section.delete
      return { success: true }
    else
      return { success: false, messages: object.errors.full_messages }
    end
  end

end

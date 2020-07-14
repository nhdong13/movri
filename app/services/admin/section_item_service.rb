class Admin::SectionItemService
  attr_accessor :section

  def initialize(section)
    @section = section
  end

  def create item_models, item_params
    section_item = section.send(item_models).new(item_params)
    if section_item.save
      return { success: true, item: section_item.as_json }
    else
      return { success: false, messages: section_item.errors.full_messages }
    end
  end

  def update item, item_params
    if item.update_attributes(item_params)
      return { success: true, item: item.as_json }
    else
      return { success: false, messages: item.errors.full_messages }
    end
  end 

  def destroy item
    if item.destroy
      return { success: true }
    else
      return { success: false, messages: item.errors.full_messages }
    end
  end
end
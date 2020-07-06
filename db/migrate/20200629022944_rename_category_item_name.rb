class RenameCategoryItemName < ActiveRecord::Migration[5.2]
  def change
    rename_column :store_category_items, :store_category_item_id, :store_category_id
  end
end

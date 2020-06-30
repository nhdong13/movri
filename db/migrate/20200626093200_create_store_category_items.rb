class CreateStoreCategoryItems < ActiveRecord::Migration[5.2]
  def change
    create_table :store_category_items do |t|
      t.references :store_category_item
      t.integer :category_id
      t.attachment :image
      t.timestamps
    end
  end
end

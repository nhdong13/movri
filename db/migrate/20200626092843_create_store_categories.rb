class CreateStoreCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :store_categories do |t|
      t.references :online_store
      t.string :heading
      
      t.timestamps
    end
  end
end

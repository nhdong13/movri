class CreateStoreFeaturedProductItems < ActiveRecord::Migration[5.2]
  def change
    create_table :store_featured_product_items do |t|
      t.references :store_featured_product
      t.integer :product_id
      t.timestamps
    end
  end
end

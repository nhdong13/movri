class CreateStoreFeaturedProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :store_featured_products do |t|
      t.references :online_store
      t.string :heading
      t.timestamps
    end
  end
end

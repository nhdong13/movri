class CreateCategoryListings < ActiveRecord::Migration[5.2]
  def change
    create_table :category_listings do |t|
      t.integer :category_id
      t.integer :listing_id

      t.timestamps
    end
  end
end

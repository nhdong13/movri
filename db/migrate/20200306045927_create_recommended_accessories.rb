class CreateRecommendedAccessories < ActiveRecord::Migration[5.2]
  def change
    create_table :recommended_accessories do |t|
      t.integer :listing_accessory_id
      t.integer :listing_id

      t.timestamps
    end
  end
end

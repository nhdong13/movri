class CreateListingCombos < ActiveRecord::Migration[5.2]
  def change
    create_table :listing_combos do |t|
      t.integer :listing_combo_id
      t.integer :listing_id
      t.integer :quantity, default: 1
      t.integer :position
      t.timestamps
    end
  end
end

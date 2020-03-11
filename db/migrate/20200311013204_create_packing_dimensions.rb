class CreatePackingDimensions < ActiveRecord::Migration[5.2]
  def change
    create_table :packing_dimensions do |t|
      t.decimal :height
      t.decimal :length
      t.decimal :width
      t.decimal :weight
      t.integer :listing_id

      t.timestamps
    end
  end
end

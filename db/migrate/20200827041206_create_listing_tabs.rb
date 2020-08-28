class CreateListingTabs < ActiveRecord::Migration[5.2]
  def change
    create_table :listing_tabs do |t|
      t.string :title
      t.string :tab_type
      t.text :description
      t.integer :listing_id
      t.boolean :is_active, default: true
      t.integer :order_number

      t.timestamps
    end
  end
end

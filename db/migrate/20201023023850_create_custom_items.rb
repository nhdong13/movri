class CreateCustomItems < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_items do |t|
      t.integer :transaction_id
      t.string :name
      t.float :price_cents, default: 0
      t.integer :quantity
      t.integer :discount_percent, default: 0
      t.integer :discount_value, default: 0
      t.string :note
      t.integer :custom_item_type, default: 0
      t.timestamps
    end
  end
end

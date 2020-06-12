class CreateTransactionItems < ActiveRecord::Migration[5.2]
  def change
    create_table :transaction_items do |t|
      t.integer :transaction_id
      t.integer :listing_id
      t.binary :listing_uuid, limit: 16
      t.integer :listing_title
      t.integer :quantity
      t.integer :coverage_price_cents
      t.integer :price_cents
      t.timestamps
    end
  end
end

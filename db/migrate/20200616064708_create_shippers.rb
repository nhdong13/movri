class CreateShippers < ActiveRecord::Migration[5.2]
  def change
    create_table :shippers do |t|
      t.integer :transaction_id
      t.string :service_delivery
      t.string :service_type
      t.string :service_name
      t.float :amount
      t.string :currency
      t.timestamps
    end
  end
end

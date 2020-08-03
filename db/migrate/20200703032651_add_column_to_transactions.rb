class AddColumnToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :billing_address_id, :integer
    add_column :transactions, :shipping_address_id, :integer
    add_column :people, :default_shipping_address, :integer
    add_column :people, :default_billing_address, :integer
  end
end

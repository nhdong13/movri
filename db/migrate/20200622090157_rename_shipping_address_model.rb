class RenameShippingAddressModel < ActiveRecord::Migration[5.2]
  def self.up
    add_column :shipping_addresses, :address_type, :integer, default: 0
    rename_table :shipping_addresses, :transaction_addresses
  end

  def self.down
    remove_column :transaction_addresses, :address_type
    rename_table :transaction_addresses, :shipping_addresses
  end
end

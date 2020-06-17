class AddColumnsToShippingAddress < ActiveRecord::Migration[5.2]
  def change
    add_column :shipping_addresses, :email, :string
    add_column :shipping_addresses, :is_office_address, :boolean, default: false
  end
end

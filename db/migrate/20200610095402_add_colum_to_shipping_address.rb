class AddColumToShippingAddress < ActiveRecord::Migration[5.2]
  def change
    add_column :shipping_addresses, :person_id, :integer
    add_column :shipping_addresses, :first_name, :string
    add_column :shipping_addresses, :last_name, :string
    add_column :shipping_addresses, :company, :string
    add_column :shipping_addresses, :apartment, :string
    remove_column :shipping_addresses, :name
  end
end

class AddOfficeAddressFieldToTransactionAddress < ActiveRecord::Migration[5.2]
  def change
    add_column :transaction_addresses, :office_state_or_province, :string
    add_column :transaction_addresses, :office_postal_code, :string
    add_column :transaction_addresses, :office_street1, :string
    add_column :transaction_addresses, :office_city, :string
  end
end

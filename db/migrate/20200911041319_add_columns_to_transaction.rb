class AddColumnsToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :tracking_number, :string
    add_column :transactions, :shipping_carrier, :string
  end
end

class AddColumnToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :order_number, :integer, unique: true
  end
end

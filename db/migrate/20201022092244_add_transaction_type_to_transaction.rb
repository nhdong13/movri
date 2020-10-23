class AddTransactionTypeToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :transaction_type, :integer, default: 0
  end
end

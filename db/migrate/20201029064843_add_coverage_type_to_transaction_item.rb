class AddCoverageTypeToTransactionItem < ActiveRecord::Migration[5.2]
  def change
    add_column :transaction_items, :coverage_type, :integer, default: 0
    TransactionItem.update_all(coverage_type: 0)
  end
end

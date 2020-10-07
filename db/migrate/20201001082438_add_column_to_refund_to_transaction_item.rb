class AddColumnToRefundToTransactionItem < ActiveRecord::Migration[5.2]
  def change
    add_column :transaction_items, :is_deleted, :boolean, default: false
    add_column :transaction_items, :deleted_at, :datetime
    add_column :transaction_items, :note, :string
  end
end

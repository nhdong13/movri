class AddSoftDeleteToTransactionAddress < ActiveRecord::Migration[5.2]
  def change
    add_column :transaction_addresses, :is_deleted, :boolean, default: false
    add_column :transaction_addresses, :deleted_at, :datetime
  end
end

class RemoveColumnOutofAddress < ActiveRecord::Migration[5.2]
  def change
    remove_column :transaction_addresses, :transaction_id
  end
end

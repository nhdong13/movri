class AddColumnCompletedAtToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :completed_at, :datetime
  end
end

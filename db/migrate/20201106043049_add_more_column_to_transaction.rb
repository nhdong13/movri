class AddMoreColumnToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :fulfilled_at, :datetime
    add_column :transactions, :cancelled_at, :datetime
    add_column :transactions, :payment_status, :integer, default: 0
  end
end

class ChangeColumnTransaction < ActiveRecord::Migration[5.2]
  def change
    change_column :transactions, :starter_uuid, :binary, limit: 16, null: true
  end
end

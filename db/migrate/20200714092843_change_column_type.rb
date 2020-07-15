class ChangeColumnType < ActiveRecord::Migration[5.2]
  def change
    change_column :helpful_link_items, :text, :text
  end
end

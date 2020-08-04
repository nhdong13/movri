class AddColumnToCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :category_type, :integer, default: 0
  end
end

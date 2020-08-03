class ChangeColumnListing < ActiveRecord::Migration[5.2]
  def change
    change_column :listings, :available_quantity, :integer, default: 0
  end
end

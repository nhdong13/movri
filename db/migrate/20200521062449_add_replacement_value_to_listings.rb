class AddReplacementValueToListings < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :replacement_value, :integer, default: 0
  end
end

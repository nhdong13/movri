class AddColumnWeightTypeToListings < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :weight_type, :integer
  end
end

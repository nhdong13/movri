class AddPositionColumnToRecommendedAccessories < ActiveRecord::Migration[5.2]
  def change
    add_column :recommended_accessories, :position, :integer
  end
end

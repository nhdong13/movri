class AddColumnToFeaturedProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :store_featured_products, :button_text_color, :string, default: '#fff'
  end
end

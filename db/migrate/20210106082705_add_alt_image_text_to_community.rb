class AddAltImageTextToCommunity < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :image_alt_text, :string
  end
end

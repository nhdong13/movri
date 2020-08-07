class AddFacebookPixelIdToCommunities < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :facebook_pixel_id, :string
  end
end

class AddMetaTitleAndDescForListing < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :meta_title, :string
    add_column :listings, :meta_description, :text
  end
end

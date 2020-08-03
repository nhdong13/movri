class AddColumnToListing < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :listing_type, :integer, default: 0
    add_column :listings, :mount, :string
    add_column :listings, :lens_type, :string
    add_column :listings, :compatibility, :string
  end
end

class AddBrandToListing < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :brand, :string
  end
end

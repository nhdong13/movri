class AddMasterAvailableToListing < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :master_available, :integer, default: 0
    Listing.all.each{|listing| listing.update(master_available: listing.available_quantity)}
  end
end

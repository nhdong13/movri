class AddRentalTimeToListing < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :number_of_rent, :integer, default: 0
  end
end

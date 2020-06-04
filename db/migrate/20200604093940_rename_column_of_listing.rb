class RenameColumnOfListing < ActiveRecord::Migration[5.2]
  def change
    rename_column :listings, :replacement_value, :replacement_cents_fee
  end
end

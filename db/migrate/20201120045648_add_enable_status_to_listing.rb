class AddEnableStatusToListing < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :enable, :boolean, default: true
  end
end

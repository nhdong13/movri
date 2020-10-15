class AddUrlLinkToListing < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :url, :string
  end
end

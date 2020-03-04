class AddColumnVideoToListings < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :video, :string
  end
end

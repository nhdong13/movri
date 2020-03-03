class CreateListingVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :listing_videos do |t|
      t.attachment :video
      t.integer :author
      t.integer :listing_id

      t.timestamps
    end
  end
end

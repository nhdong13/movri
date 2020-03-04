class RemoveTableListingVideos < ActiveRecord::Migration[5.2]
  def change
    drop_table :listing_videos
  end
end

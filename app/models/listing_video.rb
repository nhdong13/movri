# == Schema Information
#
# Table name: listing_videos
#
#  id                 :bigint           not null, primary key
#  video_file_name    :string(255)
#  video_content_type :string(255)
#  video_file_size    :integer
#  video_updated_at   :datetime
#  author             :integer
#  listing_id         :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class ListingVideo < ApplicationRecord
  belongs_to :listing

  has_attached_file :video, styles: {
    :medium => {
      :geometry => "640x480",
      :format => 'mp4'
    },
    :thumb => { :geometry => "160x120", :format => 'jpeg', :time => 10}
  }, :processors => [:transcoder]

  validates_attachment_content_type :video, content_type: /\Avideo\/.*\Z/, less_than: 6.megabytes
end

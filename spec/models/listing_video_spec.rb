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

require 'rails_helper'

RSpec.describe ListingVideo, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

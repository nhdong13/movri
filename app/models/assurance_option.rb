# == Schema Information
#
# Table name: assurance_options
#
#  id                 :bigint           not null, primary key
#  title              :string(255)
#  content            :text(65535)
#  visible            :boolean          default(FALSE)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  community_id       :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_assurance_options_on_community_id  (community_id)
#

class AssuranceOption < ApplicationRecord
  belongs_to :community

  has_attached_file :image, default_url: "/images/missing_image.png"
  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end

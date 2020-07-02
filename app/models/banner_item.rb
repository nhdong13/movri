# == Schema Information
#
# Table name: banner_items
#
#  id                  :bigint           not null, primary key
#  highlight_banner_id :bigint
#  image_file_name     :string(255)
#  image_content_type  :string(255)
#  image_file_size     :integer
#  image_updated_at    :datetime
#  heading             :string(255)
#  sub_heading         :string(255)
#  text                :text(65535)
#  link                :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_banner_items_on_highlight_banner_id  (highlight_banner_id)
#

class BannerItem < ApplicationRecord
  validates :heading, presence: true
  has_attached_file :image, default_url: "/images/missing_image.png"
  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  def as_json
    super.merge({image_url: image.url})
  end
end

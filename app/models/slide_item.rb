# == Schema Information
#
# Table name: slide_items
#
#  id                 :bigint           not null, primary key
#  slideshow_id       :bigint
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  heading            :string(255)
#  sub_heading        :string(255)
#  text_color         :string(255)      default("#000")
#  background_link    :string(255)
#  text_alignment     :integer          default("left")
#  button_label       :string(255)
#  button_link        :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_slide_items_on_slideshow_id  (slideshow_id)
#

class SlideItem < ApplicationRecord

  validates :heading, presence: true
  has_attached_file :image, default_url: "/images/missing_image.png"
  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  enum text_alignment: %w(left center right)

  def as_json
    super.merge({image_url: image.url})
  end
end

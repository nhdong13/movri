# == Schema Information
#
# Table name: store_category_items
#
#  id                 :bigint           not null, primary key
#  store_category_id  :bigint
#  category_id        :integer
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_store_category_items_on_store_category_id  (store_category_id)
#

class StoreCategoryItem < ApplicationRecord
  has_attached_file :image, default_url: "/images/missing_image.png"
  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  enum button_style: %w(primary)
  enum width: %w(half_width)

  def as_json
    super.merge({image_url: image.url})
  end
end

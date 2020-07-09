# == Schema Information
#
# Table name: store_grid_items
#
#  id                 :bigint           not null, primary key
#  store_grid_id      :bigint
#  heading            :string(255)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  text               :text(65535)
#  text_color         :string(255)      default("#000")
#  link               :string(255)
#  button_text        :string(255)
#  button_style       :integer          default(0)
#  width              :integer          default(0)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_store_grid_items_on_store_grid_id  (store_grid_id)
#

class StoreGridItem < ApplicationRecord
  has_attached_file :image, default_url: "/images/missing_image.png"
  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  def as_json
    super.merge({image_url: image.url})
  end
end

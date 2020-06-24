# == Schema Information
#
# Table name: slideshows
#
#  id              :bigint           not null, primary key
#  header_id       :integer
#  enabled         :boolean          default(TRUE)
#  auto_play       :boolean          default(TRUE)
#  slide_duration  :integer          default(8)
#  slide_height    :integer          default(0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  online_store_id :integer
#
# Indexes
#
#  index_slideshows_on_header_id        (header_id)
#  index_slideshows_on_online_store_id  (online_store_id)
#

class Slideshow < ApplicationRecord
  belongs_to :header
  has_many :slide_items, dependent: :destroy

  def as_json
    json = super
    json['slide_items'] = slide_items.as_json
    json
  end
end

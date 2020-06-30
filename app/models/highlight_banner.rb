# == Schema Information
#
# Table name: highlight_banners
#
#  id               :bigint           not null, primary key
#  online_store_id  :bigint
#  enabled          :boolean          default(TRUE)
#  text_color       :string(255)      default("#000")
#  background_color :string(255)      default("#FFF")
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_highlight_banners_on_online_store_id  (online_store_id)
#

class HighlightBanner < ApplicationRecord
  has_many :banner_items, dependent: :destroy

  def as_json
    super.merge({banner_items: banner_items.as_json})
  end
end

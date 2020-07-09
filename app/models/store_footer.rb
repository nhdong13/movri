# == Schema Information
#
# Table name: store_footers
#
#  id               :bigint           not null, primary key
#  online_store_id  :bigint
#  name             :string(255)
#  enabled          :boolean          default(FALSE)
#  text_color       :string(255)      default("#000")
#  background_color :string(255)      default("#fff")
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_store_footers_on_online_store_id  (online_store_id)
#

class StoreFooter < ApplicationRecord
  include Sectionable
  has_many :store_footer_items, dependent: :destroy

  def as_json
    super.merge(items: store_footer_items.as_json)
  end

end

# == Schema Information
#
# Table name: store_categories
#
#  id              :bigint           not null, primary key
#  online_store_id :bigint
#  heading         :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_store_categories_on_online_store_id  (online_store_id)
#

class StoreCategory < ApplicationRecord
  has_many :store_category_items, dependent: :destroy

  def as_json
    super.merge({items: store_category_items.as_json})
  end
end

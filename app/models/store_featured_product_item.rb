# == Schema Information
#
# Table name: store_featured_product_items
#
#  id                        :bigint           not null, primary key
#  store_featured_product_id :bigint
#  product_id                :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_store_featured_product_items_on_store_featured_product_id  (store_featured_product_id)
#

class StoreFeaturedProductItem < ApplicationRecord
end

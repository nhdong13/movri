# == Schema Information
#
# Table name: store_footer_items
#
#  id              :bigint           not null, primary key
#  store_footer_id :bigint
#  heading         :string(255)
#  sub_heading     :string(255)
#  text            :text(65535)
#  link            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_store_footer_items_on_store_footer_id  (store_footer_id)
#

class StoreFooterItem < ApplicationRecord
end

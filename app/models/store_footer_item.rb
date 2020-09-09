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
#  content_type    :integer          default("normal")
#  languages       :text(4294967295)
#  currency        :text(4294967295)
#
# Indexes
#
#  index_store_footer_items_on_store_footer_id  (store_footer_id)
#

class StoreFooterItem < ApplicationRecord
  serialize :languages, Array 
  serialize :currency, Array
  enum content_type: %w(normal language currency)
end

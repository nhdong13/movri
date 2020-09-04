# == Schema Information
#
# Table name: listing_tabs
#
#  id           :bigint           not null, primary key
#  title        :string(255)
#  tab_type     :string(255)
#  description  :text(65535)
#  listing_id   :integer
#  is_active    :boolean          default(TRUE)
#  order_number :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class ListingTab < ApplicationRecord
  TAB_TYPES = ["specs", "overview", "q_and_a", "in_the_box", "not_in_the_box", "key_features"]
  belongs_to :listing
  scope :extra_tabs, -> { where.not(tab_type: TAB_TYPES) }
end

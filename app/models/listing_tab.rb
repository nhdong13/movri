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
  belongs_to :listing
end

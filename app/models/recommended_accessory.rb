# == Schema Information
#
# Table name: recommended_accessories
#
#  id                   :bigint           not null, primary key
#  listing_accessory_id :integer
#  listing_id           :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class RecommendedAccessory < ApplicationRecord
  belongs_to :listing
  belongs_to :listing_accessory, class_name: :Listing, foreign_key: :listing_accessory_id
end

# == Schema Information
#
# Table name: recommended_accessories
#
#  id                   :bigint           not null, primary key
#  listing_accessory_id :integer
#  listing_id           :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  position             :integer
#

class RecommendedAccessory < ApplicationRecord
  belongs_to :listing
  belongs_to :listing_accessory, class_name: :Listing, foreign_key: :listing_accessory_id

  after_destroy :re_order_recommended_accessories

  private

  def re_order_recommended_accessories
    RecommendedAccessory.where(listing_id: listing_id)
                .order(position: :asc)
                .each_with_index{ |item, index| item.update(position: index+1) }
  end
end

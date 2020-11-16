# == Schema Information
#
# Table name: recommended_alternatives
#
#  id                     :bigint           not null, primary key
#  listing_alternative_id :integer
#  listing_id             :integer
#  position               :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class RecommendedAlternative < ApplicationRecord
  belongs_to :listing
  belongs_to :listing_alternative, class_name: :Listing, foreign_key: :listing_alternative_id

  after_destroy :re_order_recommended_alternatives

  private

  def re_order_recommended_alternatives
    RecommendedAlternative.where(listing_id: listing_id)
                .order(position: :asc)
                .each_with_index{ |item, index| item.update(position: index+1) }
  end
end

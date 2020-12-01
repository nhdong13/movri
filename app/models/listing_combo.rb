# == Schema Information
#
# Table name: listing_combos
#
#  id               :bigint           not null, primary key
#  listing_combo_id :integer
#  listing_id       :integer
#  quantity         :integer          default(1)
#  position         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class ListingCombo < ApplicationRecord
  belongs_to :listing
  belongs_to :combo, class_name: :Listing, foreign_key: :listing_combo_id

  after_destroy :re_order_listing_combos
  after_create :update_listing_become_combo

  private
  def update_listing_become_combo
    listing.combo!
  end

  def re_order_listing_combos
    ListingCombo.where(listing_id: listing_id)
                .order(position: :asc)
                .each_with_index{ |item, index| item.update(position: index+1) }
  end
end

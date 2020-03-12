class ListingUpdateAccessoryService
  attr_reader :recommended_accessory_ids, :listing

  def initialize(recommended_accessory_ids, listing)
    @recommended_accessory_ids = recommended_accessory_ids
    @listing = listing
  end

  def add_recommended_accessories
    listing.recommended_accessories.destroy_all
    position = 1
    recommended_accessory_ids.each do |listing_id|
      ActiveRecord::Base.transaction do
        listing.recommended_accessories.create(listing_accessory_id: listing_id, position: position)
        position += 1
      end
    end
  end
end
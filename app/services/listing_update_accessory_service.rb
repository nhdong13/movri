class ListingUpdateAccessoryService
  attr_reader :recommended_accessory_ids, :listing

  def initialize(recommended_accessory_ids, listing)
    @recommended_accessory_ids = recommended_accessory_ids
    @listing = listing
  end

  def add_recommended_accessories
    listing.recommended_accessories.destroy_all
    listing_ids.each do |listing_id|
      listing.recommended_accessories.create(listing_accessory_id: listing_id)
    end
  end

  private

  def listing_ids
    Listing.where(id: recommended_accessory_ids).ids
  end
end
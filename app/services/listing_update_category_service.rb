class ListingUpdateCategoryService
  attr_reader :category_ids, :listing

  def initialize(category_ids, listing)
    @category_ids = category_ids
    @listing = listing
  end

  def create_or_update_categories
    old_category_listing_ids = listing.category_listings.destroy_all
    category_ids.each do |category_id|
      listing.category_listings.create(category_id: category_id)
    end
  end
end
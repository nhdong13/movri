class ListingSearchService
  attr_reader :keyword
  
  def initialize(keyword)
    @keyword = keyword
  end

  def search
    return Listing.none if keyword.blank?
    Listing.select(:id, :title).where('LOWER(title) LIKE ?', "%#{keyword.downcase}%")
  end
end
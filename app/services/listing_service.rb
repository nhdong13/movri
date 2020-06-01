class ListingService

  def initialize
    @listings = Listing.all
  end

  def index params
    @listings = sort_by_params params[:sort_condition]
  end

  def sort_by_params condition
    case condition
    when 'most_popular'
      @listings = @listings
    when 'newest'
      @listings = @listings.order(updated_at: :asc)
    when 'price_low_first'
      @listings = @listings.order(price_cents: :asc)
    when 'price_high_first'
      @listings = @listings.order(price_cents: :desc)
    else
      @listings
    end
  end
end
module PriceCalculationService
  module_function

  def calculate_total_price(session)
    total_price = 0

    # listing_id => total
    # e.g: {"8"=>2, "7"=>1}
    session[:cart].each do |key, value|
      listing = Listing.find_by(id: key)

      total_price += PriceCalculationService.calculate(
        listing,
        ListingViewUtils.get_booking_days(session)
      ) * value
    end

    total_price
  end

  def calculate(listing, days = 7)
    a_day_price = listing.price.cents

    day_price = a_day_price - (a_day_price * PriceCalculationService.get_discount_percent(days)/100)

    # rounding the price
    ((day_price * days)/100).to_i * 100
  end

  def get_discount_percent(days)
    case days
    when 2
      DiscountConstants::TWO_DAYS
    when 3
      DiscountConstants::THREE_DAYS
    when 4
      DiscountConstants::FOUR_DAYS
    when 5
      DiscountConstants::FIVE_DAYS
    when 6
      DiscountConstants::SIX_DAYS
    when 7
      DiscountConstants::SEVEN_DAYS
    when 8
      DiscountConstants::EIGHT_DAYS
    else
      DiscountConstants::SEVEN_DAYS
    end
  end

end

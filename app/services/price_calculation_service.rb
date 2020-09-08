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
    if days == 1
      a_day_price
    else
      day_price = a_day_price - (a_day_price * PriceCalculationService.get_discount_percent(days)/100)
      # rounding the price
      ((day_price * days)/100).to_i * 100
    end
  end

  def get_discount_percent(days)
    DISCOUNT_CONSTANS["#{days}_days"]
  end

  def get_discount_from_promo_code(price, promo_code)
    return 0 unless promo_code
    case promo_code.promo_type
    when 'discount_10_percent'
      discount = price.percent_of(10)
    when 'discount_20_percent'
      discount = price.percent_of(20)
    else
      0
    end
  end

  def calculate_tax_fee price, canada_provinces=nil
    canada_provinces = 'alberta' unless canada_provinces
    price.percent_of(get_persent_of_canada_provinces(canada_provinces))
  end

  def to_cents value
     value * CONVERT_TO_CENT_VALUE
  end

  def get_persent_of_canada_provinces canada_provinces
    case canada_provinces
    when 'alberta'
      5
    when 'british_columbia'
      12
    when 'manitoba'
      12
    when 'new_brunswick'
      15
    when 'newfoundland_and_labrador'
      15
    when 'northwest_territories'
      5
    when 'nova_scotia'
      15
    when 'nunavut'
      5
    when 'ontario'
      13
    when 'prince_edward_island'
      15
    when 'quebec'
      14.975
    when 'saskatchewan'
      11
    when 'yukon'
      5
    end
  end

  def get_rate_type_of_canada_provinces canada_provinces
    case canada_provinces
    when 'alberta'
      {GST: 5}
    when 'british_columbia'
      {GST: 7, PST: 5}
    when 'manitoba'
      {GST: 7, PST: 5}
    when 'new_brunswick'
      {HST: 15}
    when 'newfoundland_and_labrador'
      {HST: 15}
    when 'northwest_territories'
      {GST: 5}
    when 'nova_scotia'
      {HST: 15}
    when 'nunavut'
      {GST: 5}
    when 'ontario'
      {HST: 13}
    when 'prince_edward_island'
      {HST: 15}
    when 'quebec'
      {GST: 9.975, PST: 5}
    when 'saskatchewan'
      {GST: 6, PST: 5}
    when 'yukon'
      {GST: 5}
    else
      {GST: 5}
    end
  end
end

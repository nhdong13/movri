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
    tax = Tax.find_by(province: canada_provinces)
    return 5 unless tax
    persent = 0
    tax.tax_rates.each {|k,v| persent += v.to_f}
    persent.to_i == persent ? persent.to_i : persent
  end

  def get_rate_type_of_canada_provinces canada_provinces
    tax = Tax.find_by(province: canada_provinces)
    return {GST: 5} unless tax
    tax.tax_rates
  end
end

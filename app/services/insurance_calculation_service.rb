module InsuranceCalculation
  module_function

  MIN_INSURANCE_PRICE = 5

  def call(listing, booking_dates)
    return MIN_INSURANCE_PRICE unless booking_dates.to_i > 0

    price_dates = booking_dates + 2

    # 0.1% of listing replacement_value
    insurance_price_per_day = 0.001 * listing.replacement_value * price_dates

    return MIN_INSURANCE_PRICE unless MIN_INSURANCE_PRICE < insurance_price_per_day

    insurance_price_per_day
  end
end

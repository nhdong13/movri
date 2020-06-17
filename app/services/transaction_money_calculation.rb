class TransactionMoneyCalculation
  def initialize(transaction, session)
    @transaction = transaction
    @session = session
    @promo_code = @transaction.promo_code
    @state = @transaction.shipping_address ? @transaction.shipping_address.state_or_province : 'alberta'
    @shipping_fee = @transaction.shipper ? @transaction.shipper.amount : 0
  end

  def get_discount_for_all_products_cart
    get_discount_from_promo_code(
      get_price_cents_for_all_products_cart
    )
  end

  def get_discount_from_promo_code(price)
    return 0 unless @promo_code
    case @promo_code.promo_type
    when 'discount_10_percent'
      discount = price.percent_of(10)
    when 'discount_20_percent'
      discount = price.percent_of(20)
    else
      0
    end
    discount
  end

  # this value is not including coverage
  def get_price_cents_for_all_products_cart
    price_cents = 0
    @transaction.transaction_items.each do |item|
      listing = Listing.find_by(id: item.listing_id)
      price_cents += calculate_price_cents_without_promo_code(listing, item.quantity)
    end
    price_cents
  end

  def calculate_price_cents listing, quantity
    return 0 unless quantity
    price_cents = PriceCalculationService.calculate(listing, ListingViewUtils.get_booking_days(@session)) * quantity
    price_with_promo_code(price_cents)
  end

  def calculate_price_cents_without_promo_code listing, quantity
    return 0 unless quantity
    price_cents = PriceCalculationService.calculate(listing, ListingViewUtils.get_booking_days(@session)) * quantity
  end

  def price_with_promo_code price
    return price unless @promo_code
    discount = get_discount_from_promo_code(price)
    price - discount
  end

  # this value is including coverage
  def listings_subtotal
    listings_subtotal = 0
    @transaction.transaction_items.each do |item|
      listing = Listing.find_by(id: item.listing_id)
      listings_subtotal += listing_subtotal(listing, item.quantity)
    end
    listings_subtotal
  end

  def listing_subtotal listing, quantity
    price_cents = calculate_price_cents(listing, quantity)
    total_coverage = total_coverage(listing, quantity)
    price_cents + total_coverage
  end

  def total_coverage listing, quantity
    InsuranceCalculationService.call(listing, @session[:booking][:total_days]) * quantity
  end

  def get_tax_fee shipping_fee=nil
    shipping_fee = 0 if @transaction.will_pickup?
    all_fee = listings_subtotal - get_discount_for_all_products_cart + shipping_fee
    PriceCalculationService.calculate_tax_fee(all_fee, @state)
  end

  def final_price shipping_fee=nil
    shipping_fee = 0 if @transaction.will_pickup?
    tax_fee = get_tax_fee(shipping_fee)
    listings_subtotal - get_discount_for_all_products_cart + shipping_fee + tax_fee
  end
end
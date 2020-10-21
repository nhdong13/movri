class TransactionMoneyCalculation
  def initialize(transaction, session, current_user)
    @transaction = transaction
    @current_user = current_user
    @session = session
    @promo_code = @transaction.promo_code
    @state = @transaction.shipping_address ? @transaction.shipping_address.state_or_province : 'alberta'
    @shipping_fee = @transaction.shipper ? @transaction.shipper.amount_to_cents : 0

    @duration = @transaction.booking&.duration || @session[:booking][:total_days]
  end

  def get_discount_for_all_products_cart
    get_discount_from_promo_code(
      get_price_cents_for_all_products_cart
    )
  end

  def percent_of(value, percent)
    value.to_f * percent.to_f / 100.0
  end

  def get_discount_from_promo_code(price)
    return 0 unless @promo_code
    case @promo_code.promo_type
    when 'percentage'
      discount = percent_of(price, @promo_code.discount_value)
    when 'fixed_amount'
      @promo_code.fixed_amount_cents_value
    else
      0
    end
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
    price_cents = PriceCalculationService.calculate(listing, @duration) * quantity
    price_with_promo_code(price_cents)
  end

  def calculate_price_cents_without_promo_code listing, quantity
    return 0 unless quantity
    price_cents = PriceCalculationService.calculate(listing, @duration) * quantity
  end

  def price_with_promo_code price
    return price unless @promo_code
    result = PromoCodeService.new(@promo_code, @session, @current_user).check_if_promo_code_can_use
    return price unless result[:success]
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
    price_cents = calculate_price_cents_without_promo_code(listing, quantity)
    total_coverage = total_coverage(listing, quantity)
    price_cents + total_coverage
  end

  def total_coverage listing, quantity
    InsuranceCalculationService.call(listing, @duration) * quantity
  end

  def get_tax_fee state=nil, shipping_fee=nil
    shipping_fee = @transaction.will_pickup? ? 0 : @shipping_fee
    state = state ? state : @state
    all_fee = listings_subtotal - get_discount_for_all_products_cart + shipping_fee
    PriceCalculationService.calculate_tax_fee(all_fee, state)
  end

  def final_price state=nil, shipping_fee=nil
    shipping_fee = @transaction.will_pickup? ? 0 : @shipping_fee
    state = state ? state : @state
    tax_fee = get_tax_fee(state, shipping_fee)
    listings_subtotal - get_discount_for_all_products_cart + shipping_fee + tax_fee
  end

  def total_coverage_for_all_items_cart
    total_coverage = 0
    @transaction.transaction_items.each do|item|
      listing = item.listing
      coverage = InsuranceCalculationService.call(listing, @duration) * item.quantity
      total_coverage += coverage
    end
    total_coverage
  end

  def calculate_tax_fee_base_on_percent percent
    shipping_fee = @transaction.will_pickup? ? 0 : @shipping_fee
    state = state ? state : @state
    all_fee = listings_subtotal - get_discount_for_all_products_cart + shipping_fee
    percent_of(all_fee, percent)
  end
end
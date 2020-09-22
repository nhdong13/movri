class PromoCodeService
  def initialize(promo_code, session, current_user, transaction=nil)
    @promo_code = promo_code
    @session = session
    @current_user = current_user
    @transaction = transaction
  end

  def check_if_promo_code_can_use
    return {success: false, message: "The discount code is expired."} unless @promo_code.can_use?
    return promo_code_can_use_in_which_products? unless promo_code_can_use_in_which_products?[:success]
    return promo_code_can_use_in_which_conditions? unless promo_code_can_use_in_which_conditions?[:success]
    return check_customer_eligibility unless check_customer_eligibility[:success]
    {success: true}
  end

  def promo_code_can_use_in_which_products?
    case @promo_code.applies_to
    when 'specific_collections'
      get_listing_ids.each do |id|
        listing = Listing.find_by(id: id)
        unless is_included(@promo_code.limit_collection_ids, listing.categories.ids)
          return {success: false, message: "The discount code can't apply to this products."}
        else
          return {success: true, message: ""}
        end
      end
    when 'specific_products'
      unless is_included(@promo_code.limit_product_ids, get_listing_ids)
        return {success: false, message: "The discount code can't apply to this products."}
      else
        return {success: true, message: ""}
      end
    else
      {success: true, message: ''}
    end
  end

  def promo_code_can_use_in_which_conditions?
    case @promo_code.minimum_requirements
    when 'minimum_purchase_amount'
      total_price = PriceCalculationService.calculate_total_price(@session)
      if total_price < @promo_code.minimum_purchase_amount_cents_value
        return {success: false, message: "The transaction subtotal is not qualify."}
      else
        return {success: true, message: ""}
      end
    when 'minimum_quantity'
      if @session[:cart].values.sum < @promo_code.usage_limit_number
        return {success: false, message: "The quantity is not qualify."}
      else
        return {success: true, message: ""}
      end
    else
      return {success: true, message: ""}
    end

  end

  def check_customer_eligibility
    case @promo_code.customer_eligibility
    when 'specific_customers'
      if is_included(@promo_code.limit_person_ids, [@current_user.id])
        return {success: true, message: ""}
      else
        return {success: false, message: "You can't use this discount code."}
      end
    else
      return {success: true, message: ""}
    end
  end

  def get_listing_ids
    if @transaction
      @transaction.transaction_items.plucks(:listing_id)
    else
      @session[:cart].keys
    end
  end

  def is_included array1, array2
    array2.all? { |e| array1.include?(e.to_s) }
  end
end
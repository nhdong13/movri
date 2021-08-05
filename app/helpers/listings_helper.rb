require 'numberic'
module ListingsHelper
  # Class is selected if conversation type is currently selected
  def get_map_tab_class(tab_name)
    current_tab_name = action_name || "map_view"
    "inbox_tab_#{current_tab_name.eql?(tab_name) ? 'selected' : 'unselected'}"
  end

  # Removes extra characters from datetime_select field
  def clear_datetime_select(&block)
    time = "</div><div class='date_select_time_container'><div class='datetime_select_time_label'>#{t('listings.form.departure_time.at')}:</div>"
    colon = "</div><div class='date_select_time_container'><div class='datetime_select_colon_label'>:</div>"
    haml_concat capture_haml(&block).gsub(":", "#{colon}").gsub("&mdash;", "#{time}").gsub("\n", '').html_safe
  end

  # Class is selected if listing type is currently selected
  def get_listing_tab_class(tab_name)
    current_tab_name = params[:type] || "list_view"
    "inbox_tab_#{current_tab_name.eql?(tab_name) ? 'selected' : 'unselected'}"
  end

  def listed_listing_title(listing)
    format_listing_title(listing.shape_name_tr_key, listing.title)
  end

  def format_listing_title(shape_tr_key, listing_title)
    listing_shape_name = t(shape_tr_key)
    # TODO remove this hotfix when we have admin ui for translations
    if listing_shape_name.include?("translation missing")
      listing_title
    else
      "#{listing_shape_name}: #{listing_title}"
    end
  end

  def localized_category_label(category)
    return nil if category.nil?

    return category.url_name.capitalize
  end

  def localized_category_from_id(category_id)
    Maybe(category_id).map { |cat_id|
      Category.where(id: cat_id).first
    }.map { |category|
      category.url_name.capitalize
    }.or_else(nil)
  end

  def localized_listing_type_label(listing_type_string)
    return nil if listing_type_string.nil?

    return t("listings.show.#{listing_type_string}", :default => listing_type_string.capitalize)
  end

  def major_currencies(hash)
    hash.inject([]) do |array, (id, attributes)|
      array ||= []
      array << [attributes[:iso_code]]
      array.sort
    end.compact.flatten
  end

  def price_as_text(listing)
    MoneyViewUtils.to_humanized(listing.price) +
    unless listing.quantity.blank? then " / #{listing.quantity}" else "" end
  end

  def has_images?(listing)
    !listing.listing_images.empty?
  end

  def with_image_frame(listing, &block)
    if self.has_images?(listing)
      images = listing.listing_images
      image_ready_count = images.where(image_processing: true).count
      if images.count > image_ready_count
        block.call(:images_ok, images.where.not(id: images.where(image_processing: true).ids))
      else
        block.call(:images_processing, nil)
      end
    elsif listing.description.blank?
      block.call(:no_description, nil)
    end
  end

  def with_quantity_text(community, listing, &block)
    buffer = []
    buffer.push(price_quantity_per_unit(listing))
    block.call(buffer.join(" ")) unless buffer.empty?
  end

  def price_quantity_slash_unit(listing)
    if listing.unit_type.present?
      "/ 7 " + ListingViewUtils.translate_unit(listing.unit_type, listing.unit_tr_key)
    elsif listing.quantity.present?
      "/ #{listing.quantity}"
    else
      ""
    end
  end

  def price_quantity_per_unit(listing)
    quantity =
      if listing.unit_type.present?
        ListingViewUtils.translate_unit(listing.unit_type, listing.unit_tr_key)
      elsif listing.quantity.present?
        listing.quantity
      else
        nil
      end

    if quantity
      t("listings.show.price.per_quantity_unit", quantity_unit: quantity)
    else
      ""
    end
  end

  def shape_name(listing)
    t(listing.shape_name_tr_key)
  end

  def action_button_label(listing)
    t(listing.action_button_tr_key)
  end

  def listing_search_status_titles
    if params[:status].present?
      I18n.t("admin.communities.listings.status.selected_js") + params[:status].size.to_s
    else
      I18n.t("admin.communities.listings.status.all")
    end
  end

  def calculate_price_cents listing, quantity, promo_code=nil
    return 0 unless quantity
    price_cents = PriceCalculationService.calculate(listing, ListingViewUtils.get_booking_days(session)) * quantity
    price_with_promo_code(price_cents, promo_code)
  end

  def total_coverage listing, quantity
    # InsuranceCalculationService.call(listing, session[:booking][:total_days]) * quantity
    0
  end

  def total_coverage_for_all_items_cart
    total_coverage = 0
    # session[:cart].each do|listing_id, quantity|
    #   session[:coverage] ||= {}
    #   coverage_type = session[:coverage][listing_id]
    #   listing = Listing.find_by(id: listing_id)
    #   if coverage_type == "no_coverage"
    #     coverage = 0
    #   else
    #     coverage = InsuranceCalculationService.call(listing, session[:booking][:total_days]) * quantity
    #   end
    #   total_coverage += coverage
    # end
    total_coverage
  end

  def price_with_all_fee promo_code=nil, shipping_fee=nil
    shipping_fee =  FEDEX_STANDARD_FEE unless shipping_fee
    # price_with_promo_code(PriceCalculationService.calculate_total_price(session), promo_code) + total_coverage_for_all_items_cart + shipping_fee
    # TODO: remove coverage at the moment
    price_with_promo_code(PriceCalculationService.calculate_total_price(session), promo_code) + shipping_fee
  end

  def price_with_promo_code price, promo_code
    return price unless promo_code
    result = PromoCodeService.new(promo_code, session, @current_user).check_if_promo_code_can_use
    return price unless result[:success]
    discount = PriceCalculationService.get_discount_from_promo_code(price, promo_code)
    price - discount
  end

  def subtotal_in_view
    PriceCalculationService.calculate_total_price(session)
  end

  def get_today
    Date.today.strftime("%m/%d/%Y")
  end

  def money_to_humanized value
    MoneyViewUtils.to_humanized(Money.new(value, 'USD'))
  end

  def to_CAD value
    value = value.to_f / 100
    value.round(2)
  end

  def date_to_humanized date
    date.to_date.to_formatted_s(:long)
  end

  def get_discount_value price, promo_code
    return 0 unless promo_code
    case promo_code.promo_type
    when 'percentage'
      discount = price.percent_of(promo_code.discount_value)
    when 'fixed_amount'
      promo_code.fixed_amount_cents_value
    else
      0
    end

  end


  def get_invertory_history_data version
    changeset = version.changeset
    available_quantity_changeset = changeset[:available_quantity]
    if available_quantity_changeset
      number_of_rent_changeset = changeset[:number_of_rent]
      adjustment = available_quantity_changeset[1].to_i - available_quantity_changeset[0].to_i
      action = adjustment >= 0 ? 'positive' : 'negative'

      event = ''
      if action == 'positive' && number_of_rent_changeset.nil?
        event = 'Manually added'
      elsif action == 'negative' && number_of_rent_changeset.nil?
        event = 'Manually subtracted'
      elsif action == 'negative' && number_of_rent_changeset.present?
        event = 'Order created'
      end
      {
        date: version.created_at.in_time_zone.strftime("%b %d, at %H:%M %P %Z"),
        event: event,
        adjusted_by: version.whodunnit,
        adjustment: adjustment,
        action: action
      }
    else
      nil
    end
  end

  def maximum_available_quantity listing
    [1, listing.master_available].max
  end

  def disabled_qty listing
    from_qty = [listing.available_quantity, 1].max
    (from_qty + 1..listing.master_available).to_a
  end

end

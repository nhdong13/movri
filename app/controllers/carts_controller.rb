class CartsController < ApplicationController
  def get_shipping_rates_for_listing_items
    listing_ids = session[:cart].keys
    listings = Listing.where(id: listing_ids)

    if params[:zipcode].blank? || listings.blank?
      @message = "Wrong or missing parameters"
    end

    listings.each do |listing|
      if listing.packing_dimensions.blank?
        @message = "The listing has not dimensions to calculate"
      end
    end
    result = ShippingRatesService.get_shipping_rates_for_cart_page(params, session[:cart])
    if result[:success]
      @shipping_selection = result[:shipping_selection]
      session[:shipping][:fedex] = @shipping_selection
    else
      @message = result[:message]
    end
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  def change_cart_detail_booking_days
    return unless params[:start_date] && params[:end_date]
    # pass same value for start and end date
    @success = true
    if params[:start_date] == params[:end_date]
      @success = false
      @message = "You cannot choose Arrival Date and Return Date the same"
    end
    # pass same value in session
    if session[:booking] && params[:start_date] == session[:booking][:start_date] && params[:end_date] == session[:booking][:end_date]
      @success = false
    end

    data = BookingDaysCalculation.call(params)

    # Set to session
    session[:booking] ||= {}
    session[:booking][:start_date] = data[:start_date]
    session[:booking][:end_date] = data[:end_date]
    session[:booking][:total_days] = data[:total_days]

    @promo_code = PromoCode.find_by(code: params[:code])
    @shipping_type = params[:shipping_type]

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def change_cart_select_shipping
    @promo_code = PromoCode.find_by(code: params[:code])
    @shipping_type = params[:shipping_type]
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
end

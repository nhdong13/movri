class CartsController < ApplicationController
  before_action do
    @promo_code = PromoCode.find_by(code: params[:code])
  end

  def get_shipping_rates_for_listing_items
    listing_ids = session[:cart].keys
    listings = Listing.where(id: listing_ids)

    if params[:zipcode].blank? || listings.blank?
      @message = "Wrong or missing parameters"
    end

    listings.each do |listing|
      if listing.packing_dimensions.blank?
        # TODO: create packing_dimension only for test, remove this line when app release
        PackingDimension.create(height: 10, length:10, width: 10, weight: 10, listing_id: listing.id)
        # @message = "The listing has not dimensions to calculate"
      end
    end
    result = ShippingRatesService.get_shipping_rates_for_cart_page(listing_ids, params[:zipcode], session[:cart].values.sum)
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
    # pass same value in session
    if session[:booking] && params[:start_date] == session[:booking][:start_date] && params[:end_date] == session[:booking][:end_date]
      @success = false
    end

    data = BookingDaysCalculation.call(params[:start_date], params[:end_date])

    # Set to session
    session[:booking] ||= {}
    session[:booking][:start_date] = data[:start_date]
    session[:booking][:end_date] = data[:end_date]
    session[:booking][:total_days] = data[:total_days]

    @shipping_type = params[:shipping_type]

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def change_cart_select_shipping
    @shipping_type = params[:shipping_type]
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
end

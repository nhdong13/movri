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
    else
      @message = result[:message]
    end
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end
end

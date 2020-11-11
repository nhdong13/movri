class WishListsController < ApplicationController
  def add_to_wish_list
    @listing = Listing.find(params[:id])
    @can_add_to_wish_list = true
    if @current_user
      if @current_user.wish_lists.include?(@listing)
        @message = "This product is already in your wish list!"
        @can_add_to_wish_list = false
      else
        @message = "Added the product to wish list successfully!"
        @current_user.wish_lists << @listing
        #syn data with agolia
        @listing.touch
      end
    else
      @message = "Please login first!"
      @can_add_to_wish_list = false
    end
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end
end

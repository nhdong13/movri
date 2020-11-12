class WishListsController < ApplicationController
  def add_to_wish_list
    @listing = Listing.find_by(id: params[:id])
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

  def remove_out_of_wish_list
    @listing = Listing.find_by(id: params[:id])
    if @listing
      @current_user.wish_lists.delete(@listing)
      #syn data with agolia
      @listing.touch
    end
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  def add_wish_list_item_to_cart
    @listing = Listing.find_by(id: params[:id])
    # Return if listing does not eixst
    # Add item to session
    if @listing
      session[:cart] ||= {}
      listing_id = params[:id]
      session[:cart][listing_id] = session[:cart][listing_id] ? (session[:cart][listing_id].to_i + 1) : 1
      transaction_items_service.add_new_transaction_items(listing_id) if transaction_items_service
    end
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  def move_to_wish_list
    @listing = Listing.find_by(id: params[:id])
    # Add item to session
    @can_add_to_wish_list = true
    if @current_user
      @message = "Added the product to wish list successfully!"
      unless @current_user.wish_lists.include?(@listing)
        @current_user.wish_lists << @listing
        #syn data with agolia
        @listing.touch
      end
      # remove out of session
      session[:cart] ||= {}
      listing_id = params[:id]
      session[:cart].delete(listing_id)
      transaction_items_service.remove_listing_item_out_of_transaction(listing_id) if transaction_items_service
    else
      @message = "Please login first!"
      @can_add_to_wish_list = false
    end

    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  private
  def transaction_items_service
    if @current_user && @current_user.has_a_pending_transaction?
      TransactionItemsService.new(@current_user.pending_transaction, session, @current_user)
    else
      if session[:transaction] && session[:transaction][:transaction_id]
        transaction = Transaction.find_by(id: session[:transaction][:transaction_id])
        if transaction && !transaction.completed?
          TransactionItemsService.new(transaction, session, nil)
        end
      end
    end
  end
end

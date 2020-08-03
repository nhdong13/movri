class TransactionItemsService
  def initialize(transaction, session, user)
    @transaction = transaction
    @session = session
    @user = user
  end

  def reduce_quantity_of_transaction_items listing_id, quantity=nil
    item = @transaction.transaction_items.find_by(listing_id: listing_id)
    return unless item
    if quantity
      item.update(quantity: quantity)
    else
      item.update(quantity: item.quantity - 1)
    end
    remove_listing_item_out_of_transaction(item.listing_id) if item.quantity < 1
  end

  def remove_listing_item_out_of_transaction listing_id
    item = @transaction.transaction_items.find_by(listing_id: listing_id)
    item.delete
  end

  def increase_quantity_of_transaction_items listing_id, quantity=nil
    item = @transaction.transaction_items.find_by(listing_id: listing_id)
    return unless item
    if quantity
      item.update(quantity: quantity)
    else
      item.update(quantity: item.quantity + 1)
    end
  end

  def add_new_transaction_items listing_id
    item = @transaction.transaction_items.find_by(listing_id: listing_id)
    if item
      item.update(quantity: item.quantity + 1)
    else
      listing = Listing.find_by(id: listing_id)
      @transaction.transaction_items.create(
        listing_id: listing.id,
        listing_uuid: listing.uuid,
        listing_title: listing.title,
        quantity: 1,
        coverage_price_cents: InsuranceCalculationService.call(listing, @session[:booking][:total_days]),
        price_cents: listing.price_cents
      )
    end
  end
end
class KlaviyoService
  def initialize(transaction, session, user)
    @transaction = transaction
    @session = session
    @user = user
    @calculate_money_service = TransactionMoneyCalculation.new(@transaction, @session, @user)
    @shipping_address = @transaction.shipping_address
    @billing_address = @transaction.billing_address
  end

  def get_data_for_placed_order
    json = {
      "token": APP_CONFIG.klaviyo_public_api_key,
      "event": "Placed Order",
      "customer_properties": customer_properties(),
      "properties": {
        "$event_id": "#{@transaction.id}_#{Time.now.to_i}",
        "$value": MoneyViewUtils.to_CAD(@calculate_money_service.final_price),
        "OrderId": @transaction.id,
        "Categories": @transaction.categories,
        "DiscountCode": @transaction.promo_code ? @transaction.promo_code.code : "",
        "DiscountValue": @calculate_money_service.get_discount_for_all_products_cart,
        "Items": transaction_items(),
        "BillingAddress": billing_address_properties(),
        "ShippingAddress": shipping_address_properties(),
      },
      "time": Time.now.to_i
    }
    json
  end

  def transaction_items
    @transaction.transaction_items.map do |item|
      listing = item.listing
      if listing
        {
          'ProductID': listing.id,
          'SKU': listing.sku,
          'ProductName': listing.title,
          'Quantity': item.quantity,
          'ItemPrice': MoneyViewUtils.to_CAD(listing.price_cents),
          'ImageURL': listing.main_image,
          'ProductCategories': listing.categories.pluck(:display_title)
        }
      end
    end
  end

  def customer_properties
    {
      "$email": @shipping_address.email,
      "$first_name": @shipping_address.first_name,
      "$last_name": @shipping_address.last_name,
      "$phone_number": @shipping_address.phone,
      "$address1": @shipping_address.street1,
      "$address2": @shipping_address.street2,
      "$city": @shipping_address.city,
      "$zip": @shipping_address.postal_code,
      "$country": "CA"
    }
  end

  def shipping_address_properties
    {
      "FirstName": @shipping_address.first_name,
      "LastName": @shipping_address.last_name,
      "Company": @shipping_address.company,
      "Address1": @shipping_address.street1,
      "Address2": @shipping_address.street2,
      "City": @shipping_address.city,
      "Country": "Canada",
      "CountryCode": "CA",
      "Zip": @shipping_address.postal_code,
      "Phone": @shipping_address.phone
    }
  end

  def billing_address_properties
    {
      "FirstName": @billing_address.first_name,
      "LastName": @billing_address.last_name,
      "Company": @billing_address.company,
      "Address1": @billing_address.street1,
      "Address2": @billing_address.street2,
      "City": @billing_address.city,
      "Country": "Canada",
      "CountryCode": "CA",
      "Zip": @billing_address.postal_code,
      "Phone": @billing_address.phone
    }
  end

  def get_data_for_fulfill_order
    json = {
      "token": APP_CONFIG.klaviyo_public_api_key,
      "event": "Fulfilled Order",
      'customer_properties': customer_properties(),
      "properties": {
        '$event_id': "#{@transaction.id}_#{Time.now.to_i}",
        "$value": MoneyViewUtils.to_CAD(@calculate_money_service.final_price),
        "OrderId": @transaction.id,
        "Categories": @transaction.categories,
        "DiscountCode": @transaction.promo_code ? @transaction.promo_code.code : "",
        "DiscountValue": @calculate_money_service.get_discount_for_all_products_cart,
        "Items": transaction_items(),
        "BillingAddress": billing_address_properties(),
        "ShippingAddress": shipping_address_properties(),
      },
      "time": Time.now.to_i
    }
    json
  end

  def get_data_for_cancelled_order
    json = {
      "token": APP_CONFIG.klaviyo_public_api_key,
      "event": "Cancelled Order",
      'customer_properties': customer_properties(),
      "properties": {
        "Reason": @transaction.reason_for_cancelling,
        "$event_id": "#{@transaction.id}_#{Time.now.to_i}",
        "$value": MoneyViewUtils.to_CAD(@calculate_money_service.final_price),
        "OrderId": @transaction.id,
        "Categories": @transaction.categories,
        "DiscountCode": @transaction.promo_code ? @transaction.promo_code.code : "",
        "DiscountValue": @calculate_money_service.get_discount_for_all_products_cart,
        "Items": transaction_items(),
        "BillingAddress": billing_address_properties(),
        "ShippingAddress": shipping_address_properties(),
      },
      "time": Time.now.to_i
    }
    json
  end

  def get_data_for_refunded_order
    json = {
      "token": APP_CONFIG.klaviyo_public_api_key,
      "event": "Cancelled Order",
      'customer_properties': customer_properties(),
      "properties": {
        "Reason": @transaction.stripe_payments.refund.last.note,
        "$event_id": "#{@transaction.id}_#{Time.now.to_i}",
        "$value": MoneyViewUtils.to_CAD(@calculate_money_service.final_price),
        "OrderId": @transaction.id,
        "Categories": @transaction.categories,
        "DiscountCode": @transaction.promo_code ? @transaction.promo_code.code : "",
        "DiscountValue": @calculate_money_service.get_discount_for_all_products_cart,
        "Items": transaction_items(),
        "BillingAddress": billing_address_properties(),
        "ShippingAddress": shipping_address_properties(),
      },
      "time": Time.now.to_i
    }
    json
  end
end

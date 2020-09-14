module ShippingRatesService
  module_function

  def create_body_request_to_postmen(params)
    listing = Listing.find_by(id: params[:id])
    ship_to_postal_code = params[:zipcode] || "V3R0N2"
    packing_dimension = listing.packing_dimensions.first
    dimension = {
      width: packing_dimension.width || 10,
      height: packing_dimension.height || 10,
      depth: packing_dimension.length || 10,
      weight: packing_dimension.weight || 1
    }
    listing_weight = listing.weight || dimension[:weight]
    listing_sku = listing.sku.present? ? listing.sku : "required_field"
    listings_quantity = params[:listings_quantity] || 1
    state_from_postal_code = convert_postal_code_to_state_in_canada(ship_to_postal_code)
    quantity = 1
    request_body(ship_to_postal_code, state_from_postal_code, dimension, quantity, listing_sku)
  end

  def dimension_params listings
    width = 0; height = 0; depth = 0; weight = 0;
    listings.each do |listing|
      packing_dimension = listing.packing_dimensions.first
      width  += packing_dimension.width
      height += packing_dimension.height
      depth  += packing_dimension.length
      weight += packing_dimension.weight
    end
    # get average
    dimension = {
      width:  width/listings.size,
      height: height/listings.size,
      depth:  depth/listings.size,
      weight: weight/listings.size
    }
  end

  def request_body ship_to_postal_code, state_from_postal_code, dimension, quantity, sku
    hash_body = {
      async: false,
      shipper_accounts:[
        # {id: APP_CONFIG.fedex_shipper_id},
        {id: APP_CONFIG.ups_shipper_id}
      ],
      is_document:false,
      shipment: {
        ship_from: {
          contact_name: "[FedEx] Contact name",
          company_name: "[FedEx] Testing Company",
          street1: APP_CONFIG.store_address_street,
          country: APP_CONFIG.store_address_country,
          type: "business",
          postal_code: APP_CONFIG.store_address_postal_code,
          city: APP_CONFIG.store_address_city,
          phone: APP_CONFIG.contact_phone,
          state: APP_CONFIG.store_address_state,
          email: APP_CONFIG.sales_email
        },
        ship_to:{
          postal_code: ship_to_postal_code,
          state: state_from_postal_code,
          country:"CA",
          type:"residential"
        },
        parcels:[
          {
            description:"Food XS",
            box_type:"custom",
            weight:{"value": dimension[:weight] * quantity, "unit":"kg"},
            dimension:{width: dimension[:width], height: dimension[:height], depth: dimension[:depth], unit:"cm"},
            items:[
              {
                description:"Get shipping rates for listing",
                quantity: quantity,
                price:{amount:3, currency:"USD"},
                weight:{value: dimension[:weight], unit: "kg"},
                sku: sku
              }
            ]
          }
        ]
      }
    }
    hash_body.to_json
  end

  def create_body_request_to_postmen_with_multiple_listings listing_ids, zipcode, total_quantity
    listings = Listing.where(id: listing_ids)
    dimension = dimension_params(listings)
    ship_to_postal_code = zipcode || "V3R0N2"
    weight_average = dimension[:weight]
    # TODO: define skus later
    listing_skus = "required_field"
    quantity = total_quantity
    state_from_postal_code = convert_postal_code_to_state_in_canada(ship_to_postal_code)
    request_body(ship_to_postal_code, state_from_postal_code, dimension, quantity, listing_skus)
  end

  def get_shipping_rates_for_cart_page listing_ids, zipcode , total_quantity
    request_body = create_body_request_to_postmen_with_multiple_listings(listing_ids, zipcode, total_quantity)

    response = Faraday.post(
      APP_CONFIG.postmen_get_shipping_rates_url,
      request_body,
      "Content-Type" => "application/json",
      "postmen-api-key" => APP_CONFIG.postmen_api_key
    )
    response_body = JSON.parse(response.body)
    if response_body["meta"]["code"] == 200 && response_body["data"]["rates"][0]["total_charge"]
      shipping_selection = convert_to_shipping_selection(response_body)
      return {success: true, shipping_selection: shipping_selection}
    else
      return {success: false, message: 'Something went wrong.'}
    end

  end

  def convert_to_shipping_selection response
    rates = response["data"]["rates"]
    shipping_selection = []
    rates.each do |rate|
      shipping_selection.push(
        {
          'service_name' => rate['service_name'],
          'total_charge' => add_shipping_additional_fee(rate['total_charge']),
          'service_type' => rate['service_type']
        }
      )
    end
    shipping_selection
  end

  def add_shipping_additional_fee total_charge
    amount = total_charge["amount"]
    return unless amount
    additional_fee = ShippingAdditionalFee.last
    total_fee_percent = additional_fee.handling + additional_fee.insurance
    final_fee = amount + (amount * total_fee_percent / 100)
    total_charge['amount'] = final_fee.round(2)
    total_charge
  end

  def convert_postal_code_to_state_in_canada(postal_code)
    case postal_code[0].upcase
    when "A"
      return "NL"
    when "B"
      return "NS"
    when "C"
      return "PE"
    when "E"
      return "NB"
    when "G"
      return "QC"
    when "H"
      return "QC"
    when "J"
      return "QC"
    when "K"
      return "ON"
    when "L"
      return "ON"
    when "M"
      return "ON"
    when "N"
      return "ON"
    when "P"
      return "ON"
    when "R"
      return "MB"
    when "S"
      return "SK"
    when "T"
      return "AB"
    when "V"
      return "BC"
    when "X"
      return "NU"
    when "Y"
      return "YT"
    else
    end
  end
end

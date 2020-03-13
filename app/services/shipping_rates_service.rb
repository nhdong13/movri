module ShippingRatesService
  module_function

  def create_body_request_to_postmen(params)
    listing = Listing.find_by(id: params[:id])
    ship_to_postal_code = params[:zipcode] || "V3R0N2"
    packing_dimension = listing.packing_dimensions.first
    dimension = {
      width: packing_dimension.width,
      height: packing_dimension.height,
      depth: packing_dimension.length,
      weight: packing_dimension.weight
    }
    listing_weight = listing.weight || dimension[:weight]
    listing_sku = listing.sku.present? ? listing.sku : "required_field"
    listings_quantity = params[:listings_quantity] || 1
    state_from_postal_code = convert_postal_code_to_state_in_canada(ship_to_postal_code)

    hash_body = {
      async: false,
      shipper_accounts:[{id: APP_CONFIG.test_fedex_shipper_id}],
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
            weight:{"value": dimension[:weight], "unit":"kg"},
            dimension:{width: dimension[:width], height: dimension[:height], depth: dimension[:depth], unit:"cm"},
            items:[
              {
                description:"Get shipping rates for listing",
                quantity: listings_quantity,
                price:{amount:3, currency:"USD"},
                weight:{value: listing_weight, unit: "kg"},
                sku: listing_sku
              }
            ]
          }
        ]
      }
    }


    hash_body.to_json
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

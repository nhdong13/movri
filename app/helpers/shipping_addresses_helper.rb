module ShippingAddressesHelper
  def shipping_type_to_humanized shipping_type
    case shipping_type
    when "fedex_ground"
      "3 business days"
    when "fedex_standard_overnight"
      "1 business day"
    when "fedex_priority_overnight"
      "1 business day"
    else
    end
  end
end

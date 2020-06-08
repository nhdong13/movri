module CartsHelper

  def shipping_options options
    if options[:fedex]
      options[:fedex].map{|type| ["#{type['service_name']} - #{type['total_charge']['amount']} #{type['total_charge']['currency']}", type['service_type']]}
    end
  end

  def select_method_shipping shipping_list_method, booking_date
    difference_in_days = (Date.strptime(booking_date[:start_date], "%m/%d/%Y") - Date.today()).to_i
    # auto choose 3 days Fedex shipping if usr start days as anytime after 4 business day
    if difference_in_days >= 4
      'fedex_express_saver'
    else
      'fedex_priority_overnight'
    end
  end

  def calculate_shipping_fee shipping_list_method, booking_date, shipping_type=nil
    shipping_type = select_method_shipping(shipping_list_method, booking_date) unless shipping_type
    shipping_fee = 0
    shipping_list_method[:fedex].map{ |type| shipping_fee = type["total_charge"]["amount"] if type["service_type"] == shipping_type}
    # convert to cent
    shipping_fee * CONVERT_TO_CENT_VALUE
  end
end

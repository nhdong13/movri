class SendgridMailer
  NEW_ORDER_TEMPLATE_ID = ''
  ORDER_CONFIRMED_TEMPLATE_ID = 'd-5a3616cf9af646e8ba9b277126a4101d'
  ORDER_FULFILLED_TEMPLATE_ID = 'd-d94c4ae064d149aea1cc7c3817336077'
  ORDER_DELIVERED_TEMPLATE_ID = 'd-17d8394abcc747bfb1dd3641c9e29c3a'
  ORDER_RETURN_REMINDER_TEMPLATE_ID = 'd-709940f55b9c41d0bf1af567bbfa5dc5'
  ORDER_RECEIVED_TEMPLATE_ID = 'd-cb16da8e31174951b37a1a7e44ad3ac7'
  PAYMENT_ERROR_EMAIL_TEMPLATE_ID = 'd-1f7a88f66cf143d0a78dedbe752bad6c'
  ORDER_INVOICE_EMAIL_TEMPLATE_ID = 'd-09d81bdc6e4b4b5f8f234afa7197b519'
  REFUND_NOTIFICATION_EMAIL_TEMPLATE_ID = 'd-3c4452e2cf4b4d49a05fc40a478d3688'
  ORDER_CANCELLED_EMAIL_TEMPLATE_ID = 'd-28c1411907e64eb88fade388ca33b696'
  ORDER_DELIVERED_TEMPLATE_ID = 'd-ecf7fd441f6b467d81c1c758a5bff3c8'
  CONFIRMATION_EMAIL_TEMPLATE_ID = 'd-034b300e1e50486ea68c39f821d26865'
  WELCOME_EMAIL_TEMPLATE_ID = 'd-2f165bb3f7ce4595ad235928c4dd7d55'
  SERVICE_EMAIL = 'sales@movri.ca'
  CART_URL = "#{APP_CONFIG.smtp_email_domain}/cart"
  ROUTES_URL = APP_CONFIG.smtp_email_domain

  def initialize(transaction=nil, session={}, current_user=nil)
    @session = session
    @transaction = transaction
    @current_user = current_user
    if @transaction
      @calculate_money_service = TransactionMoneyCalculation.new(@transaction, @session, @current_user)
    end
  end

  def to_CAD value
    value = value.to_f / 100
    value.round(2)
  end

  def send_notification_to_admin
    shipping_address = @transaction.shipping_address
    billing_address = @transaction.billing_address
    subsitutions = {
      order_number: @transaction.order_number,
      first_name: shipping_address.first_name,
      last_name: shipping_address.last_name,
      shipping_address_line_1: shipping_address.street1,
      shipping_address_city: shipping_address.city,
      shipping_address_state_province_region:  CANADA_PROVINCES.key(shipping_address.state_or_province),
      shipping_address_postal_code: shipping_address.postal_code,
      country: shipping_address.country,
      billing_address_line_1: billing_address.street1,
      billing_address_city: billing_address.city,
      billing_address_state_province_region:  CANADA_PROVINCES.key(billing_address.state_or_province),
      billing_address_postal_code: billing_address.postal_code,
      shop_email: SERVICE_EMAIL,
      Sender_Name: "Movri Admin",
      Sender_Address: OFFICE_ADDRESS[:street1],
      Sender_State: CANADA_PROVINCES.key(OFFICE_ADDRESS[:state_or_province]),
      Sender_City: OFFICE_ADDRESS[:city],
      Sender_Zip: OFFICE_ADDRESS[:postal_code],
      payment_processing_method: 'Stripe',
      delivery_method: @transaction.shipper.service_delivery.capitalize,
      item: {
        products: get_items_from_transaction()
      },
    }.merge(get_data_from_transaction())

    data = {
      "personalizations": [
        {
          "to": [
            {
              "email": SERVICE_EMAIL
            }
          ],
          "dynamic_template_data": subsitutions
        }
      ],
      "from": {
        "email": SERVICE_EMAIL
      },
      "template_id": ORDER_RECEIVED_TEMPLATE_ID
    }
    sg = SendGrid::API.new(api_key: APP_CONFIG.SENDGRID_API_KEY)
    begin
      response = sg.client.mail._("send").post(request_body: data)
      return response.status_code
    rescue Exception => e
      puts e.message
    end
  end

  def send_confirmation_mail email, community
    @current_community = community
    @resource = email.person
    @confirmation_token = email.confirmation_token
    @host = community.full_domain
    email.update_attribute(:confirmation_sent_at, Time.now)
    confirm_email_url = "#{ROUTES_URL}/en/people/confirmation?confirmation_token=#{@confirmation_token}"
    subsitutions = {
      confirm_email_url: confirm_email_url,
      first_name: @resource.given_name,
      shop_email: SERVICE_EMAIL,
    }

    data = {
      "personalizations": [
        {
          "to": [
            {
              "email": email.address
            }
          ],
          "dynamic_template_data": subsitutions
        }
      ],
      "from": {
        "email": SERVICE_EMAIL
      },
      "template_id": CONFIRMATION_EMAIL_TEMPLATE_ID
    }
    sg = SendGrid::API.new(api_key: APP_CONFIG.SENDGRID_API_KEY)
    begin
      response = sg.client.mail._("send").post(request_body: data)
      return response.status_code
    rescue Exception => e
      puts e.message
    end
  end

  def send_welcome_mail person
    subsitutions = {
      shop_email: SERVICE_EMAIL,
      shop: {
        url: ROUTES_URL
      }
    }

    data = {
      "personalizations": [
        {
          "to": [
            {
              "email": person.confirmed_notification_emails_to
            }
          ],
          "dynamic_template_data": subsitutions
        }
      ],
      "from": {
        "email": SERVICE_EMAIL
      },
      "template_id": WELCOME_EMAIL_TEMPLATE_ID
    }
    sg = SendGrid::API.new(api_key: APP_CONFIG.SENDGRID_API_KEY)
    begin
      response = sg.client.mail._("send").post(request_body: data)
      return response.status_code
    rescue Exception => e
      puts e.message
    end
  end

  def send_new_order_mail(to, subsitutions)
    subsitutions = {header: 'Test email', first_name: 'Admin', last_name: 'Movri'}
    data = {
      "personalizations": [
        {
          "to": [
            {
              "email": to
            }
          ],
          "dynamic_template_data": subsitutions
        }
      ],
      "from": {
        "email": SERVICE_EMAIL
      },
      "template_id": ORDER_CONFIRMED_TEMPLATE_ID
    }
    sg = SendGrid::API.new(api_key: APP_CONFIG.SENDGRID_API_KEY)
    begin
      response = sg.client.mail._("send").post(request_body: data)
      return response.status_code
    rescue Exception => e
      puts e.message
    end
  end

  def send_order_delivered_mail tracking_number
    shipping_address = @transaction.shipping_address
    email_to = shipping_address.email
    subsitutions = {
      carrier_method: @transaction.shipping_carrier.upcase,
      tracking_number: tracking_number,
      shop_email: SERVICE_EMAIL,
      item: {
        products: get_items_from_transaction()
      },
    }.merge(get_data_from_transaction())

    data = {
      "personalizations": [
        {
          "to": [
            {
              "email": email_to
            }
          ],
          "dynamic_template_data": subsitutions
        }
      ],
      "from": {
        "email": SERVICE_EMAIL
      },
      "template_id": ORDER_DELIVERED_TEMPLATE_ID
    }
    sg = SendGrid::API.new(api_key: APP_CONFIG.SENDGRID_API_KEY)
    begin
      response = sg.client.mail._("send").post(request_body: data)
      return response.status_code
    rescue Exception => e
      puts e.message
    end

  end

  def send_order_fulfilled_mail
    shipping_address = @transaction.shipping_address
    email_to = shipping_address.email
    subsitutions = {
      order_number: @transaction.order_number,
      first_name: shipping_address.first_name,
      last_name: shipping_address.last_name,
      tracking_number: @transaction.tracking_number,
      shop_email: SERVICE_EMAIL,
      shop_url: APP_CONFIG.smtp_email_domain,
      order_status_url: "",
      item: {
        products: get_items_from_transaction()
      },
    }

    data = {
      "personalizations": [
        {
          "to": [
            {
              "email": email_to
            }
          ],
          "dynamic_template_data": subsitutions
        }
      ],
      "from": {
        "email": SERVICE_EMAIL
      },
      "template_id": ORDER_FULFILLED_TEMPLATE_ID
    }
    sg = SendGrid::API.new(api_key: APP_CONFIG.SENDGRID_API_KEY)
    begin
      response = sg.client.mail._("send").post(request_body: data)
      return response.status_code
    rescue Exception => e
      puts e.message
    end
  end

  def send_payment_error_mail
    shipping_address = @transaction.shipping_address
    email_to = shipping_address.email
    subsitutions = {
      shop_email: SERVICE_EMAIL,
      url: CART_URL,
      shop_url: APP_CONFIG.smtp_email_domain,
    }

    data = {
      "personalizations": [
        {
          "to": [
            {
              "email": email_to
            }
          ],
          "dynamic_template_data": subsitutions
        }
      ],
      "from": {
        "email": SERVICE_EMAIL
      },
      "template_id": PAYMENT_ERROR_EMAIL_TEMPLATE_ID
    }
    sg = SendGrid::API.new(api_key: APP_CONFIG.SENDGRID_API_KEY)
    begin
      response = sg.client.mail._("send").post(request_body: data)
      return response.status_code
    rescue Exception => e
      puts e.message
    end
  end


  def get_items_from_transaction
    list_products = []
    @transaction.transaction_items.each do |item|
      list_products.push({
        title: item.listing.title,
        product_image_url: item.listing.main_image,
        amount: item.price_cents_to_CAD,
        quantity: item.quantity,
      })
    end
    list_products
  end

  def get_data_from_transaction
    promo_code = @transaction.promo_code ? @transaction.promo_code.code : ""
    booking = @transaction.booking
    {
      insurance_coverage: to_CAD(@calculate_money_service.total_coverage_for_all_items_cart),
      discount_code: promo_code,
      discount_value: to_CAD(@calculate_money_service.get_discount_for_all_products_cart),
      subtotal: to_CAD(@calculate_money_service.listings_subtotal),
      total_value: to_CAD(@transaction.stripe_payments.standard.last.sum_cents),
      shipping_value: @transaction.will_pickup? ? 0 : @transaction.shipper.amount,
      arrival_date: booking.start_on.strftime("%m/%d/%Y"),
      return_date: booking.end_on.strftime("%m/%d/%Y"),
      duration:booking.duration
    }
  end

  def send_refund_notification_mail refund_value
    shipping_address = @transaction.shipping_address
    email_to = shipping_address.email

    subsitutions = {
      order_number: @transaction.order_number,
      shop_email: SERVICE_EMAIL,
      refund_value: refund_value,
      item: {
        products: get_items_from_transaction()
      },
    }.merge(get_data_from_transaction())

    data = {
      "personalizations": [
        {
          "to": [
            {
              "email": email_to
            }
          ],
          "dynamic_template_data": subsitutions
        }
      ],
      "from": {
        "email": SERVICE_EMAIL
      },
      "template_id": REFUND_NOTIFICATION_EMAIL_TEMPLATE_ID
    }
    sg = SendGrid::API.new(api_key: APP_CONFIG.SENDGRID_API_KEY)
    begin
      response = sg.client.mail._("send").post(request_body: data)
      return response.status_code
    rescue Exception => e
      puts e.message
    end
  end

  def send_cancel_transaction_mail
    shipping_address = @transaction.shipping_address
    email_to = shipping_address.email
    subsitutions = {
      order_number: @transaction.order_number,
      shop_email: SERVICE_EMAIL,
      item: {
        products: get_items_from_transaction()
      },
    }.merge(get_data_from_transaction())

    data = {
      "personalizations": [
        {
          "to": [
            {
              "email": email_to
            }
          ],
          "dynamic_template_data": subsitutions
        }
      ],
      "from": {
        "email": SERVICE_EMAIL
      },
      "template_id": ORDER_CANCELLED_EMAIL_TEMPLATE_ID
    }
    sg = SendGrid::API.new(api_key: APP_CONFIG.SENDGRID_API_KEY)
    begin
      response = sg.client.mail._("send").post(request_body: data)
      return response.status_code
    rescue Exception => e
      puts e.message
    end
  end

  def send_order_confirmed_mail
    shipping_address = @transaction.shipping_address
    billing_address = @transaction.billing_address
    email_to = shipping_address.email
    subsitutions = {
      order_number: @transaction.order_number,
      first_name: shipping_address.first_name,
      last_name: shipping_address.last_name,
      shipping_address_line_1: shipping_address.street1,
      shipping_address_city: shipping_address.city,
      shipping_address_state_province_region:  CANADA_PROVINCES.key(shipping_address.state_or_province),
      shipping_address_postal_code: shipping_address.postal_code,
      country: shipping_address.country,
      billing_address_line_1: billing_address.street1,
      billing_address_city: billing_address.city,
      billing_address_state_province_region:  CANADA_PROVINCES.key(billing_address.state_or_province),
      billing_address_postal_code: billing_address.postal_code,
      shop_email: SERVICE_EMAIL,
      Sender_Name: "Movri Admin",
      Sender_Address: OFFICE_ADDRESS[:street1],
      Sender_State: CANADA_PROVINCES.key(OFFICE_ADDRESS[:state_or_province]),
      Sender_City: OFFICE_ADDRESS[:city],
      Sender_Zip: OFFICE_ADDRESS[:postal_code],
      item: {
        products: get_items_from_transaction()
      },
    }.merge(get_data_from_transaction())

    data = {
      "personalizations": [
        {
          "to": [
            {
              "email": email_to
            }
          ],
          "dynamic_template_data": subsitutions
        }
      ],
      "from": {
        "email": SERVICE_EMAIL
      },
      "template_id": ORDER_CONFIRMED_TEMPLATE_ID
    }
    sg = SendGrid::API.new(api_key: APP_CONFIG.SENDGRID_API_KEY)
    begin
      response = sg.client.mail._("send").post(request_body: data)
      return response.status_code
    rescue Exception => e
      puts e.message
    end
  end


  def send_invoice_mail(to, subsitutions)
    subsitutions = {order_number: 1, custom_message: 'Admin', total: '50', shipping: '6', taxes: '1', address: '46A Le trung nghia', city: 'Ho Chi Minh', state_province_region: 'Ho Chi Minh', postal_code: '700000', country: "Viet Nam"}
    data = {
      "personalizations": [
        {
          "to": [
            {
              "email": to
            }
          ],
          "dynamic_template_data": subsitutions
        }
      ],
      "from": {
        "email": SERVICE_EMAIL
      },
      "template_id": ORDER_INVOICE_EMAIL_TEMPLATE_ID
    }
    sg = SendGrid::API.new(api_key: APP_CONFIG.SENDGRID_API_KEY)
    begin
      response = sg.client.mail._("send").post(request_body: data)
      return response.status_code
    rescue Exception => e
      puts e.message
    end
  end
end

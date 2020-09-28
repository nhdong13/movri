class SendgridMailer
  NEW_ORDER_TEMPLATE_ID = ''
  ORDER_CONFIRMED_TEMPLATE_ID = 'd-5a3616cf9af646e8ba9b277126a4101d'
  ORDER_FULFILLED_TEMPLATE_ID = 'd-d94c4ae064d149aea1cc7c3817336077'
  ORDER_DELIVERED_TEMPLATE_ID = 'd-17d8394abcc747bfb1dd3641c9e29c3a'
  ORDER_RETURN_REMINDER_TEMPLATE_ID = 'd-709940f55b9c41d0bf1af567bbfa5dc5'
  ORDER_RECEIVED_TEMPLATE_ID = 'd-33b70e50e9144f968b4b6c19b6ec092e'
  ORDER_INVOICE_EMAIL_TEMPLATE_ID = 'd-d18795129226483ca509919fa8e53099'
  SERVICE_EMAIL = 'sales@movri.ca'

  def self.send_new_order_mail(to, subsitutions)
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

  def self.send_order_fulfilled_mail transaction
    shipping_address = transaction.shipping_address
    email_to = shipping_address.email
    subsitutions = {
      ORDER_NUMBER: transaction.order_number,
      first_name: shipping_address.first_name,
      last_name: shipping_address.last_name,
      tracking_number: transaction.tracking_number,
      shop_email: SERVICE_EMAIL,
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

  def self.send_order_confirmed_mail transaction
    shipping_address = transaction.shipping_address
    billing_address = transaction.billing_address
    email_to = shipping_address.email
    subsitutions = {
      'order-number': transaction.order_number,
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

  def self.send_order_delivered_mail(to, subsitutions)
  end

  def self.send_order_return_reminder_mail(to, subsitutions)
  end

  def self.send_order_return_received_mail(to, subsitutions)
  end

  def self.send_invoice_mail(to, subsitutions)
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

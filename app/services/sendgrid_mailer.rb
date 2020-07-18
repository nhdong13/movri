class SendgridMailer
  NEW_ORDER_TEMPLATE_ID = ''
  ORDER_CONFIRMED_TEMPLATE_ID = 'd-5a3616cf9af646e8ba9b277126a4101d'
  ORDER_FULFILLED_TEMPLATE_ID = 'd-acff11c8ea0f4e4a8dcab3a7db17be83'
  ORDER_DELIVERED_TEMPLATE_ID = 'd-17d8394abcc747bfb1dd3641c9e29c3a'
  ORDER_RETURN_REMINDER_TEMPLATE_ID = 'd-709940f55b9c41d0bf1af567bbfa5dc5'
  ORDER_RECEIVED_TEMPLATE_ID = 'd-33b70e50e9144f968b4b6c19b6ec092e'
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

  def self.send_order_confirmed_mail(to, subsitutions)
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

  def self.send_order_fulfilled_mail(to, subsitutions)
  end

  def self.send_order_delivered_mail(to, subsitutions)
  end

  def self.send_order_return_reminder_mail(to, subsitutions)
  end

  def self.send_order_return_received_mail(to, subsitutions)
  end
end

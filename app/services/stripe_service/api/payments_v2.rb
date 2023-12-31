module StripeService::API
  class PaymentsV2
    def initialize(transaction, session, current_user)
      @community =  Community.last
      @session = session
      @transaction = transaction
      @shipping_address = transaction.shipping_address
      @current_user = current_user
      Stripe.api_key = APP_CONFIG.stripe_api_secret_key
      if @transaction.draft_order?
        @calculate_money_service = TransactionMoneyCalculation.new(@transaction, @session, @current_user, false)
        @amount = @calculate_money_service.get_final_price_for_draft_order.to_i
      else
        @calculate_money_service = TransactionMoneyCalculation.new(@transaction, @session, @current_user)
        @amount = @calculate_money_service.final_price
      end
    end

    def create_payment_intent payment_method_id
      begin
        ActiveRecord::Base.transaction(:requires_new => true) do
          @transaction.draft_order? ? update_available_quantity_for_draft_order : update_available_quantity
          customer = create_stripe_customer(payment_method_id)
          update_payment_method(payment_method_id)
          intent = Stripe::PaymentIntent.create({
            amount: @amount,
            currency: 'cad',
            payment_method: payment_method_id,
            customer: customer['id'],
            error_on_requires_action: true,
            confirm: true,
            shipping: {
              address: {
                line1: @shipping_address.get_street1,
                city: @shipping_address.get_city ,
                country: 'CA',
                postal_code: @shipping_address.get_postal_code,
                state: CANADA_PROVINCES.key(@shipping_address.get_state_or_province)
              },
              name: @shipping_address.fullname
            }
          })
          increase_total_of_used_discount_code
          create_stripe_payment(intent) if intent
          unless @transaction.draft_order?
            sendgridmailer.send_order_confirmed_mail
            sendgridmailer.send_notification_to_admin
          end
          return {success: true}
        end
      rescue => e
        # Display error on client
        sendgridmailer.send_payment_error_mail
        return {success: false, error: e.message}
      end
    end

    def update_payment_method payment_method_id
      @billing_address = @transaction.billing_address
      if @billing_address
        Stripe::PaymentMethod.update(
          payment_method_id,
          billing_details: {
            address: {
              line1: @billing_address.get_street1,
              city: @billing_address.get_city ,
              country: 'CA',
              postal_code: @billing_address.get_postal_code,
              state: CANADA_PROVINCES.key(@billing_address.get_state_or_province)
            },
            name: @billing_address.fullname
          }
        )
      end
    end

    def create_stripe_payment intent
      @transaction.stripe_payments.create(
        status: 'paid',
        sum_cents: intent.amount,
        commission_cents: 0,
        fee_cents: @calculate_money_service.get_tax_fee,
        subtotal_cents: @calculate_money_service.listings_subtotal,
        stripe_payment_intent_id: intent.id,
        stripe_payment_intent_status: intent.status,
        stripe_payment_intent_client_secret: intent.client_secret
      )
    end

    def update_available_quantity
      booking = @transaction.booking
      padding_time_start = booking.start_on - @community.padding_time_before.to_i
      padding_time_end = booking.end_on + @community.padding_time_after.to_i
      @transaction.transaction_items.each do |item|
        listing = item.listing
        if listing.combo?
          listing.listing_combos.each do |listing_combo|
            listing_child = listing_combo.combo
            listing_quantity = listing_child.available_quantity
            new_quantity = listing_quantity - listing_combo.quantity
            new_quantity = new_quantity >= 0 ? new_quantity : 0
            number_of_rent = listing_child.number_of_rent + listing_combo.quantity
            listing_child.update!(available_quantity: new_quantity, number_of_rent: number_of_rent)
            update_padding_time(listing_child, padding_time_start, padding_time_end)
          end
        end

        listing_quantity = listing.available_quantity
        new_quantity = listing_quantity - item.quantity
        new_quantity = new_quantity >= 0 ? new_quantity : 0
        number_of_rent = listing.number_of_rent + item.quantity
        listing.update!(available_quantity: new_quantity, number_of_rent: number_of_rent)
        update_padding_time(listing, padding_time_start, padding_time_end)
      end
    end

    def update_available_quantity_for_draft_order
      @transaction.transaction_items.each do |item|
        listing = item.listing
        if listing
          if listing.combo?
            listing.listing_combos.each do |listing_combo|
              listing_child = listing_combo.combo
              listing_quantity = listing_child.available_quantity
              new_quantity = listing_quantity - listing_combo.quantity
              new_quantity = new_quantity >= 0 ? new_quantity : 0
              number_of_rent = listing_child.number_of_rent + listing_combo.quantity
              listing_child.update!(available_quantity: new_quantity, number_of_rent: number_of_rent)
            end
          end

          listing_quantity = listing.available_quantity
          new_quantity = listing_quantity - item.quantity
          new_quantity = new_quantity >= 0 ? new_quantity : 0
          number_of_rent = listing.number_of_rent + item.quantity
          listing.update!(available_quantity: new_quantity, number_of_rent: number_of_rent)
        end
      end
    end

    def update_padding_time listing, padding_time_start, padding_time_end
      if listing.available_quantity == 0
        if listing.padding_time
          listing.padding_time.update(start_date: padding_time_start, end_date: padding_time_end)
        else
          listing.create_padding_time(start_date: padding_time_start, end_date: padding_time_end)
        end
      end
    end

    def increase_total_of_used_discount_code
      promo_code = @transaction.promo_code
      if promo_code
        promo_code.update(number_of_uses: promo_code.number_of_uses + 1 )
        @current_user.promo_codes_used << promo_code if @current_user
      end
    end

    def create_stripe_customer stripe_payment_method_id
      if @transaction.starter
        user = @transaction.starter
        unless user.stripe_customers.any?
          customer = Stripe::Customer.create({
            email: user.get_email,
            payment_method: stripe_payment_method_id
          })
          Stripe::PaymentMethod.attach(stripe_payment_method_id,{customer: customer['id']})
          user.stripe_customers.create(stripe_customer_id: customer['id'], payment_method_id: stripe_payment_method_id)
        else
          Stripe::PaymentMethod.attach(stripe_payment_method_id, {customer: user.stripe_customers.last.stripe_customer_id})
          customer = Stripe::Customer.retrieve(user.stripe_customers.last.stripe_customer_id)
        end
      else
        email = @transaction.shipping_address&.email,
        customer = Stripe::Customer.create({email: email,payment_method: stripe_payment_method_id})
        Stripe::PaymentMethod.attach(stripe_payment_method_id, {customer: customer['id']})
        @transaction.create_stripe_customer(stripe_customer_id: customer['id'], payment_method_id: stripe_payment_method_id)
      end
      customer
    end

    def processing_billing_address_and_payment_intent params, transaction_address_params
      begin
        ActiveRecord::Base.transaction do
          if params[:billing_address_id].present?
            @transaction_address = TransactionAddress.find_by(id: params[:billing_address_id])
            @transaction_address.update(transaction_address_params)
          else
            @transaction_address = TransactionAddress.create(transaction_address_params)
          end
          @transaction.update(billing_address_id: @transaction_address.id)
          @current_user.update(default_billing_address: @transaction_address.id) if @current_user && @current_user.billing_address.nil?
          @transaction.draft_order? ? update_available_quantity_for_draft_order : update_available_quantity
          customer = create_stripe_customer(params[:stripe_payment_method_id])
          update_payment_method(params[:stripe_payment_method_id])
          intent = Stripe::PaymentIntent.create({
            amount: @amount,
            currency: 'cad',
            payment_method: params[:stripe_payment_method_id],
            error_on_requires_action: true,
            confirm: true,
            customer: customer['id'],
            shipping: {
              address: {
                line1: @shipping_address.get_street1,
                city: @shipping_address.get_city ,
                country: 'CA',
                postal_code: @shipping_address.get_postal_code,
                state: CANADA_PROVINCES.key(@shipping_address.get_state_or_province)
              },
              name: @shipping_address.fullname
            }
          })
          increase_total_of_used_discount_code
          create_stripe_payment(intent) if intent
          unless @transaction.draft_order?
            sendgridmailer.send_order_confirmed_mail
            sendgridmailer.send_notification_to_admin
          end
          return {success: true}
        end
      rescue StandardError => e
        sendgridmailer.send_payment_error_mail
        return {success: false, error: e.message}
      end
    end

    def sendgridmailer
      SendgridMailer.new(@transaction, @session, @current_user)
    end

    def create_stripe_payment_for_extra_charge intent, note, payment_type
      stripe_payment = @transaction.stripe_payments.create!(
        status: 'paid',
        sum_cents: intent.amount,
        commission_cents: 0,
        payment_type: payment_type,
        note: note,
        fee_cents: intent.amount,
        subtotal_cents: 0,
        stripe_payment_intent_id: intent.id,
        stripe_payment_intent_status: intent.status,

      )
      unless intent.object == "refund"
        stripe_payment.update(stripe_payment_intent_client_secret: intent.client_secret)
      end
    end

    def charge_extra_fee stripe_payment_params
      if @transaction.starter
        stripe_customer = @transaction.starter.stripe_customers.last
      else
        stripe_customer = @transaction.stripe_customer
      end
      begin
        ActiveRecord::Base.transaction do
          intent = Stripe::PaymentIntent.create({
            amount: stripe_payment_params[:fee_cents].to_i * 100,
            currency: 'cad',
            error_on_requires_action: true,
            confirm: true,
            customer: stripe_customer.stripe_customer_id,
            payment_method: stripe_customer.payment_method_id,
          })
          create_stripe_payment_for_extra_charge(intent, stripe_payment_params[:note], 1) if intent
          return {success: true}
        end
      rescue StandardError => e
        sendgridmailer.send_payment_error_mail
        return {success: false, error: e.message}
      end
    end

    def to_cents value
      value = value.to_f * 100
      value.to_i
    end

    def to_CAD value
      value = value.to_f / 100
    end

    def charge_refund_fee params
      begin
        amount_refund = to_cents(params[:refund_amount])
        intent = @transaction.stripe_payments.standard.last
        ActiveRecord::Base.transaction do
          # params[:refund_quantity].each do |key, quantity|
          #   transaction_item_id = key.split("_").last
          #   transaction_item = @transaction.transaction_items.find_by(id: transaction_item_id)
          #   amount_refund += transaction_item.price_cents * quantity.to_i
          #   transaction_item.update(quantity: transaction_item.quantity - quantity.to_i)
          #   if transaction_item.quantity == 0
          #     transaction_item.soft_delete
          #   end
          # end
          refund = Stripe::Refund.create({ amount: amount_refund, payment_intent: intent.stripe_payment_intent_id})
          create_stripe_payment_for_extra_charge(refund, params[:reason_refund], 2) if refund
          if params[:sent_mail_refund_to_customer] == "on"
            sendgridmailer.send_refund_notification_mail(to_CAD(amount_refund))
          end
          return {success: true}
        end
      rescue StandardError => e
        return {success: false, error: e.message}
      end
    end

    def cancel_an_order params
      begin
        amount_refund = to_cents(params[:refund_amount])
        intent = @transaction.stripe_payments.standard.last
        ActiveRecord::Base.transaction do
          if amount_refund > 0
            refund = Stripe::Refund.create({ amount: amount_refund, payment_intent: intent.stripe_payment_intent_id}) if intent
            create_stripe_payment_for_extra_charge(refund, params[:reason_for_canceling], 3) if refund
          end
          @transaction.update(current_state: 'cancelled', reason_for_cancelling: params[:reason_for_canceling])
          # @transaction.transaction_items.each do |item|
          #   item_quantity = item.quantity
          #   item.listing.update(quantity:  item.listing.quantity + item_quantity)
          # end
          if params[:sent_mail_cancel_order_to_customer] == "on"
            sendgridmailer.send_cancel_transaction_mail
            sendgridmailer.send_refund_notification_mail(to_CAD(amount_refund))
          end
          return {success: true}
        end
      rescue StandardError => e
        return {success: false, error: e.message}
      end
    end
  end
end
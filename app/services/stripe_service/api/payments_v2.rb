module StripeService::API
  class PaymentsV2
    def initialize(transaction, session, current_user)
      @community =  Community.last
      @session = session
      @transaction = transaction
      @current_user = current_user
      Stripe.api_key = APP_CONFIG.stripe_api_secret_key
      @calculate_money_service = TransactionMoneyCalculation.new(@transaction, @session, @current_user)
      @amount = @calculate_money_service.final_price.to_i
    end

    def create_payment_intent payment_method_id
      begin
        ActiveRecord::Base.transaction(:requires_new => true) do
          update_available_quantity
          customer = create_stripe_customer(payment_method_id)
          intent = Stripe::PaymentIntent.create({
            amount: @amount,
            currency: 'usd',
            payment_method: payment_method_id,
            customer: customer['id'],
            error_on_requires_action: true,
            confirm: true
          })
          create_stripe_payment(intent) if intent
          SendgridMailer.send_order_confirmed_mail(@transaction)
          return {success: true}
        end
      rescue => e
        # Display error on client
        return {success: false, error: e.message}
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
        listing_quantity = listing.available_quantity
        new_quantity = listing_quantity - item.quantity
        new_quantity = new_quantity >= 0 ? new_quantity : 0
        number_of_rent = listing.number_of_rent + item.quantity
        item.listing.update!(available_quantity: new_quantity, number_of_rent: number_of_rent)
        if listing.available_quantity == 0
          @session[:booking] = {}
          if listing.padding_time
            listing.padding_time.update(start_date: padding_time_start, end_date: padding_time_end)
          else
            listing.create_padding_time(start_date: padding_time_start, end_date: padding_time_end)
          end
        end
      end
    end

    def create_stripe_customer stripe_payment_method_id
      if @current_user
        unless @current_user.stripe_customers.any?
          customer = Stripe::Customer.create({
            email: @current_user.get_email,
            payment_method: stripe_payment_method_id
          })

          @current_user.stripe_customers.create(stripe_customer_id: customer['id'], payment_method_id: stripe_payment_method_id)
        else
          customer = Stripe::Customer.retrieve(@current_user.stripe_customers.last.stripe_customer_id)
        end
      else
        email = @transaction.shipping_address&.email,
        customer = Stripe::Customer.create({
          email: email,
          payment_method: stripe_payment_method_id
        })
        @transaction.create_stripe_customer(stripe_customer_id: customer['id'], payment_method_id: stripe_payment_method_id)
      end
      customer
    end

    def processing_billing_address_and_payment_intent params, transaction_address_params
      begin
        ActiveRecord::Base.transaction do
          amount = @calculate_money_service.final_price
          if params[:billing_address_id].present?
            @transaction_address = TransactionAddress.find_by(id: params[:billing_address_id])
            @transaction_address.update(transaction_address_params)
          else
            @transaction_address = TransactionAddress.create(transaction_address_params)
          end
          @transaction.update(billing_address_id: @transaction_address.id)
          @current_user.update(default_billing_address: @transaction_address.id) if @current_user && @current_user.billing_address.nil?

          update_available_quantity
          customer = create_stripe_customer(params[:stripe_payment_method_id])
          intent = Stripe::PaymentIntent.create({
            amount: @amount,
            currency: 'usd',
            payment_method: params[:stripe_payment_method_id],
            error_on_requires_action: true,
            confirm: true,
            customer: customer['id']
          })
          create_stripe_payment(intent) if intent
          SendgridMailer.send_order_confirmed_mail(@transaction)
          return {success: true}
        end
      rescue StandardError => e
        return {success: false, error: e.message}
      end
    end

    def create_extra_fee_stripe_payment intent, stripe_payment_params
      @transaction.stripe_payments.create!(
        status: 'paid',
        sum_cents: intent.amount,
        commission_cents: 0,
        payment_type: 1,
        note: stripe_payment_params[:note],
        fee_cents: intent.amount,
        subtotal_cents: 0,
        stripe_payment_intent_id: intent.id,
        stripe_payment_intent_status: intent.status,
        stripe_payment_intent_client_secret: intent.client_secret
      )
    end

    def charge_extra_fee stripe_payment_params
      if @transaction.starter
        stripe_customer = @transaction.starter.stripe_customer.last
      else
        stripe_customer = @transaction.stripe_customer
      end
      begin
        ActiveRecord::Base.transaction do
          intent = Stripe::PaymentIntent.create({
            amount: stripe_payment_params[:fee_cents].to_i * 100,
            currency: 'usd',
            error_on_requires_action: true,
            confirm: true,
            customer: stripe_customer.stripe_customer_id,
            payment_method: stripe_customer.payment_method_id,
          })
          create_extra_fee_stripe_payment(intent, stripe_payment_params) if intent
        end
      rescue StandardError => e
        return {success: false, error: e.message}
      end
    end
  end
end
module StripeService::API
  class PaymentsV2
    def initialize(transaction, session)
      @session = session
      @transaction = transaction
      Stripe.api_key = 'sk_test_51GvgLeA1vyHsG6ncWtahmTkplffeTuDyVGisy1wHXThu4IzsXn6GgjgvR6fOK50qLwDBMTjLEe1CLTDhBX73zZop00PrIu5PWB'
      @calculate_money_service = TransactionMoneyCalculation.new(@transaction, @session)
    end

    def create_payment_intent payment_method_id
      amount = @calculate_money_service.final_price
      intent = Stripe::PaymentIntent.create({
        amount: amount.to_i,
        currency: 'usd',
        payment_method: payment_method_id,
        error_on_requires_action: true,
        confirm: true
      })
      if intent
        create_stripe_payment(intent)
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
  end
end
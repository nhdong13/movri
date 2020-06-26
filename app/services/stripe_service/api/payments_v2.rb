module StripeService::API
  class PaymentsV2
    def initialize(transaction, session)
      @session = session
      @transaction = transaction
      Stripe.api_key = APP_CONFIG.stripe_api_test_secret_key
      @calculate_money_service = TransactionMoneyCalculation.new(@transaction, @session)
      @amount = @calculate_money_service.final_price.to_i
    end

    def create_payment_intent payment_method_id
      begin
        intent = Stripe::PaymentIntent.create({
          amount: @amount,
          currency: 'usd',
          payment_method: payment_method_id,
          error_on_requires_action: true,
          confirm: true
        })
        create_stripe_payment(intent) if intent
        return {success: true}
      rescue Stripe::CardError => e
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

    def create_billing_address_and_payment_intent params, transaction_address_params
      begin
        ActiveRecord::Base.transaction do
          amount = @calculate_money_service.final_price
          @transaction_address = @transaction.transaction_addresses.create(transaction_address_params)
          intent = Stripe::PaymentIntent.create({
            amount: @amount,
            currency: 'usd',
            payment_method: params[:stripe_payment_method_id],
            error_on_requires_action: true,
            confirm: true
          })
          create_stripe_payment(intent) if intent
          return {success: true}
        end
      rescue StandardError => e
        return {success: false, error: e.message}
      end
    end
  end
end
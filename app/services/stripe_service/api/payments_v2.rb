module StripeService::API
  class PaymentsV2
    def initialize(transaction, session, current_user)
      @session = session
      @transaction = transaction
      @current_user = current_user
      Stripe.api_key = APP_CONFIG.stripe_api_secret_key
      @calculate_money_service = TransactionMoneyCalculation.new(@transaction, @session)
      @amount = @calculate_money_service.final_price.to_i
    end

    def create_payment_intent payment_method_id
      begin
        ActiveRecord::Base.transaction(:requires_new => true) do
          update_available_quantity

          intent = Stripe::PaymentIntent.create({
            amount: @amount,
            currency: 'usd',
            payment_method: payment_method_id,
            error_on_requires_action: true,
            confirm: true
          })
          create_stripe_payment(intent) if intent
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
      @transaction.transaction_items.each do |item|
        listing = item.listing
        listing_quantity = listing.available_quantity
        new_quantity = listing_quantity - item.quantity
        new_quantity = new_quantity >= 0 ? new_quantity : 0
        number_of_rent = listing.number_of_rent + item.quantity
        item.listing.update!(available_quantity: new_quantity, number_of_rent: number_of_rent)
      end
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
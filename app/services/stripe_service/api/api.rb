module StripeService
  module API
    class Api
      def self.accounts
        @accounts ||= StripeService::API::Accounts.new
      end

      def self.wrapper
        StripeService::API::StripeApiWrapper
      end

      def self.payments
        StripeService::API::Payments
      end

      def self.payments_v2
        StripeService::API::PaymentsV2
      end
    end
  end
end

class ChargifyClient
  module Objects
    class Subscription < ChargifyClient::Objects::Base

      def apply_service_credit(options)
        client.post(
          path: apply_service_credit_path, body: wrap_in_service_credit(options)
        )
        self
      end

      def customer
        @customer ||= ChargifyClient::Util.
          create_new_object("Customer", client, chargify_hash[:customer])
      end

      def product
        @product ||= ChargifyClient::Util.
          create_new_object("Product", client, chargify_hash[:product])
      end

      def credit_card
        @credit_card ||= extract_credit_card
      end

      private

      def extract_credit_card
        ChargifyClient::Util.create_new_object(
          "CreditCard", client, chargify_hash[:credit_card]
        ) if chargify_hash[:credit_card]
      end

      def apply_service_credit_path
        "/subscriptions/#{id}/service_credits.json"
      end

      def wrap_in_service_credit(options)
        {service_credit: options}
      end

    end
  end
end

class ChargifyClient
  module Resources
    class CreditCards < ChargifyClient::Resources::Base
      def base_path
        "payment_profiles"
      end

      def find_all(params = {})
        ChargifyClient::ResponseError.disallow
      end

      def find_by_reference(reference)
        ChargifyClient::ResponseError.disallow
      end

      def create(body)
        ChargifyClient::ResponseError.disallow
      end

      protected

      def extract_my_payload_from_response(response)
        payload = super(response)
        return payload if payload
        response[:payment_profile]
      end
    end
  end
end

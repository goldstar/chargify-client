class ChargifyClient
  module Resources
    class Components < ChargifyClient::Resources::Base

      def reference_lookup_key
        :handle
      end

      def find_all(params = {})
        ChargifyClient::ResponseError.disallow
      end

      def find_by_id(id)
        ChargifyClient::ResponseError.disallow
      end

      def create(body)
        ChargifyClient::ResponseError.disallow
      end
    end
  end
end

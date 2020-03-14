class ChargifyClient
  module Resources
    class ProductFamilies < ChargifyClient::Resources::Base

      def find_by_reference(reference)
        raise ChargifyClient::ResponseError.new(405, "Method Not Allowed", nil)
      end
    end
  end
end

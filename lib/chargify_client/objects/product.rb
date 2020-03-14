class ChargifyClient
  module Objects
    class Product < ChargifyClient::Objects::Base

      def product_family
        @product_family ||= ChargifyClient::Util.
          create_new_object("ProductFamily", client, chargify_hash[:product_family])
      end
    end
  end
end

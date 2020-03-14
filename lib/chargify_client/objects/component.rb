class ChargifyClient
  module Objects
    class Component < ChargifyClient::Objects::Base

      def add_usage(options)
        validate_usage(options)
        response = client.post(path: add_usage_path(options), body: wrap_in_usage(options))
        ChargifyClient::Util.create_new_object("Usage", client, response[:usage])
      end

      def prices
        @prices ||= chargify_hash[:prices].map {|price|
                      ChargifyClient::Util.create_new_object("Price", client, price)
                    }
      end

      def product_family
        @product_family ||= client.product_families.
                              find_by_id(chargify_hash[:product_family_id])
      end

      private

      def add_usage_path(options)
        "/subscriptions/#{options[:subscription_id]}/components/#{chargify_hash[:id]}/usages.json"
      end

      def wrap_in_usage(options)
        {usage: options.except(:subscription_id)}
      end

      def validate_usage(options)
        raise_missing("subscription_id") unless options[:subscription_id]
        raise_missing("quantity") unless options[:quantity]
        raise_wrong_type unless is_metered_component?
      end

      def raise_missing(option)
        raise ChargifyClient::ResponseError.new(400, "Bad Request", "Must include #{option}")
      end

      def raise_wrong_type
        raise ChargifyClient::ResponseError.new(
          406, "Not acceptable", "Usage can only be applied to a metered component"
        )
      end

      def is_metered_component?
        chargify_hash[:kind] == "metered_component"
      end
    end
  end
end

class ChargifyClient
  module Objects
    class Base
      def initialize(client:, chargify_hash:)
        @client = client
        @chargify_hash = chargify_hash
      end

      protected

      attr_reader :client, :chargify_hash

      def method_missing(mth)
        return chargify_hash[mth] if chargify_hash[mth]
        super
      end
    end
  end
end

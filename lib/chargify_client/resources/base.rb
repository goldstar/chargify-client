require "active_support/inflector"

class ChargifyClient
  module Resources
    class Base
      def initialize(client:)
        @client = client
      end

      def base_path
        @base_path ||= my_snake_case_name
      end

      def reference_lookup_key
        :reference
      end

      def find_by_id(id)
        response = client.get(path: "#{base_path}/#{id}.json")
        new_resource_object_from_response(response)
      end

      def find_all(params = {})
        response = client.get(path: "#{base_path}.json", params: params)
        response.map {|res|
          new_resource_object_from_response(res)
        }
      end

      def find_by_reference(reference)
        response = client.get(
          path: "#{base_path}/lookup.json",
          params: build_reference_lookup_params(reference)
        )
        new_resource_object_from_response(response)
      end

      def create(body)
        response = client.post(path: "#{base_path}.json", body: wrap_as_child(body))
        new_resource_object_from_response(response)
      end

      protected

      def extract_my_payload_from_response(response)
        response[my_singular_symbolized_name]
      end

      private

      attr_reader :client

      def my_class_name
        @my_class_name ||= self.class.name.split("::").last
      end

      def my_snake_case_name
        my_class_name.underscore
      end

      def my_singular_symbolized_name
        @my_singular_symbolized_name ||= my_snake_case_name.singularize.to_sym
      end

      def object_class_name
        "ChargifyClient::Objects::#{my_class_name.singularize}"
      end

      def new_resource_object_from_response(response)
        payload_body = extract_my_payload_from_response(response)
        ChargifyClient::Util.create_new(
          object_class_name, {client: client, chargify_hash: payload_body}
        )
      end

      def wrap_as_child(body)
        full_body = {}
        full_body[my_singular_symbolized_name] = body
        full_body
      end

      def build_reference_lookup_params(reference)
        params = {}
        params[reference_lookup_key] = reference
        params
      end

    end
  end
end

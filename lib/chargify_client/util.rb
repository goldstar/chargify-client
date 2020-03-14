require "active_support"

class ChargifyClient
  class Util
    def self.create_new_resources(resources_type, client)
      class_name = "ChargifyClient::Resources::#{resources_type.camelize}"
      create_new(class_name, {client: client})
    end

    def self.create_new_object(object_type, client, args = {})
      class_name = "ChargifyClient::Objects::#{object_type.camelize}"
      create_new(class_name, {client: client, chargify_hash: args})
    end

    def self.create_new(clazz, args = nil)
      clz = clazz.constantize
      args ? clz.new(args) : clz.new
    end
  end
end

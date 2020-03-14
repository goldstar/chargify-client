require "active_support"
require "base64"
require "faraday"
require "json"

require "chargify_client/objects/base"
require "chargify_client/resources/base"
require "chargify_client/response_error"
require "chargify_client/util"

class ChargifyClient
  attr_reader :api_key, :subdomain

  def initialize(api_key:, subdomain:)
    @api_key = api_key
    @subdomain = subdomain
    populate_resources
    require_objects
  end

  def get(path:, params: {}, headers: {})
    full_path = "https://#{subdomain}.chargify.com/#{path}"
    full_headers = headers.merge(auth_header)
    response = Faraday.get(full_path, params, full_headers)
    throw_if_failed(response)
    JSON.parse(response.body, symbolize_names: true)
  end

  def post(path:, body: nil, headers: {})
    full_path = "https://#{subdomain}.chargify.com/#{path}"
    full_headers = headers.merge(auth_header).merge(content_type_header)
    json_body = body ? body.to_json : ""
    response = Faraday.post(full_path, json_body, full_headers)
    throw_if_failed(response)
    JSON.parse(response.body, symbolize_names: true) unless response.body.to_s.strip.empty?
  end

  private

  def current_path
    @current_path ||= File.expand_path(File.dirname(__FILE__))
  end

  def populate_resources
    resources_dir = File.join(current_path, "chargify_client", "resources", "*.rb")
    Dir.glob(resources_dir) do |filename|
      require filename
      add_as_method(filename) unless filename.end_with?("base.rb")
    end
  end

  def add_as_method(filename)
    raw_class_name = filename.match(/.*\/(.*)(\.rb)/)[1]
    self.class.send(:define_method, raw_class_name) do
      ChargifyClient::Util.create_new_resources(raw_class_name, self)
    end
  end

  def require_objects
    objects_dir = File.join(current_path, "chargify_client", "objects", "*.rb")
    Dir.glob(objects_dir) do |filename|
      require filename
    end
  end

  def content_type_header
    @content_type_header ||= {"Content-Type" => "application/json"}
  end

  def auth_header
    @auth_header ||= {
      authorization: "Basic #{Base64.strict_encode64("#{@api_key}:X")}"
    }
  end

  def throw_if_failed(response)
    error = ChargifyClient::ResponseError.from_response(response)
    raise(error) if error
  end
end

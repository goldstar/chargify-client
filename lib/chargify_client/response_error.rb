class ChargifyClient
  class ResponseError < StandardError
    def self.disallow
      raise ChargifyClient::ResponseError.new(405, "Method Not Allowed", nil)
    end

    def self.from_response(response)
      return if response.success?
      new(response.status, response.reason_phrase, self.parse_error_details(response))
    end

    attr_reader :status, :error_reason, :error_details

    def initialize(status, error_reason, error_details)
      super(build_message(status, error_reason, error_details))
      @status = status
      @error_reason = error_reason
      @error_details = error_details || [error_reason]
    end

    private

    def build_message(status, error_reason, error_details)
      details = Array(error_details)
      msg = details.any? ? details.join("; ") : error_reason
      return "#{status}: #{msg}"
    end

    def self.parse_error_details(response)
      env_body = response.env.body
      return if env_body.empty?
      as_json = JSON.parse(env_body)
      as_json["errors"]
    rescue
      ["unparsable error"]
    end
  end
end

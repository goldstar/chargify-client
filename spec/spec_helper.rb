require "rubygems"
require "pry"
require "vcr"

require "chargify_client"

RSpec.configure do |config|
  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end
  config.order = :random
end

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

# Instantiate a ChargifyClient to "require" all resources and objects
ChargifyClient.new(api_key: "any", subdomain: "subdomain")

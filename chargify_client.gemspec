lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chargify_client/version'

Gem::Specification.new do |s|
  s.name        = 'chargify_client'
  s.version     = ChargifyClient::VERSION
  s.date        = '2020-03-09'
  s.summary     = 'A Chargify API client for Ruby'
  s.description = ''
  s.authors     = ["Goldstar Events Development Team"]
  s.email       = 'dev@goldstar.com'
  s.homepage    = ''

  s.files       = Dir['lib/**/*.rb']
  s.test_files  = Dir['spec/**/*.rb']
  s.require_paths = ["lib"]

  # Development Dependencies
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock'
  
  s.add_runtime_dependency 'faraday'
  s.add_runtime_dependency 'activesupport'
end

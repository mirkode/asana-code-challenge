ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'webmock/rspec'

require_relative '../app'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |c|
  c.include Rack::Test::Methods
end

def app
  Coordinator
end

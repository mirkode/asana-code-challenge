require 'httparty'

require_relative 'plugs/google'
require_relative 'plugs/osm'

class Adapter
  include HTTParty

  class GeoCodingError < StandardError
    attr_reader :message

    def initialize(message)
      @message = message
    end
  end

  def initialize(query, provider = nil)
    @query = query
    @provider = provider || ENV['DEFAULT_PROVIDER'].to_sym
  end

  def get_coordinates
    locations = []
    errors = []

    provider = Object.const_get(@provider).new

    begin
      response, success = get provider.endpoint(@query)

      if success
        raise(GeoCodingError, "No results") if provider.has_no_results?(response)

        locations << provider.parsed_response(response)
      end
    rescue GeoCodingError => e
      errors << {provider: @provider, message: e.message}
    end

    {
      query: @query,
      coordinates: locations.flatten,
      errors: errors
    }.to_json
  end

  private
    def parsed_url(path)
      URI.parse(URI.escape(path))
    end

    def api_call(method, path, data = nil)
      result = self.class.send(method, parsed_url(path), body: data&.to_json || '')
      raise GeoCodingError.new("HTTP Error #{result.code}, Path: #{result.request.path}") unless [200, 201].include?(result.code)
      {
        status: result.code,
        body: JSON.parse(result.body)
      }
    end

    def get(path)
      result = api_call(:get, path)
      [result[:body], result[:status] == 200]
    end
end

require File.expand_path('../../spec_helper.rb', __FILE__)

PROVIDERS = [{
  name: 'Google',
  domain: 'maps.googleapis.com'
}, {
  name: 'OSM',
  domain: 'nominatim.openstreetmap.org'
}]

RSpec.describe "API Request", type: :request do
  context 'with no address given' do
    it 'should return a HTTP status of 400' do
      get '/search'
      expect(last_response.status).to eq(400)
    end

    it 'should provide a proper error message' do
      get '/search'
      expect(JSON.parse(last_response.body)['error'])
        .to eq('Please provide an address to look for.')
    end
  end

  shared_examples "with an address given" do |p|
    name = p&.dig(:name) || 'Google'
    domain = p&.dig(:domain) || 'maps.googleapis.com'

    it "should return the correct location of a known place (Provider: #{p ? name : 'default'})" do
      filename = "valid_#{name.downcase}_response.json"

      stub_request(:get, Regexp.new(domain))
        .to_return(status: 200,
                    body: File.read(File.join('spec', 'fixtures', filename)))

      get '/search', {address: 'Checkpoint Charlie', provider: p&.dig(:name)}.compact

      expect(JSON.parse(last_response.body))
        .to include({'query' => 'Checkpoint Charlie',
                     'coordinates' => a_collection_including(
                       a_hash_including('latitude' => 52.5074434, 'longitude' => 13.3903913)
                     ),
                     'errors' => []})
    end

    it 'should return an error if location could not be found' do
      filename = "invalid_#{name.downcase}_response.json"

      stub_request(:get, Regexp.new(domain))
        .to_return(status: 200,
                   body: File.read(File.join('spec', 'fixtures', filename)))

      get '/search', {address: 'abcdefghijklmn', provider: p&.dig(:name)}.compact
      expect(last_response.body)
        .to eq({query: 'abcdefghijklmn',
                coordinates: [],
                errors: [{
                  provider: name,
                  message: 'No results'
                }]
              }.to_json)
      end
  end

  include_examples "with an address given"

  PROVIDERS.each do |provider|
    include_examples "with an address given", provider
  end
end

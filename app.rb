require 'sinatra/base'
require 'dotenv'

class Coordinator < Sinatra::Base
  Dotenv.load

  before do
    content_type :json
  end
  get '/search' do
    unless params[:address]
      halt 400, {error: 'Please provide an address to look for.'}.to_json
    end
  end
  after do
    JSON.dump(response.body)
  end
  run! if app_file == $0
end

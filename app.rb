require 'sinatra/base'
require 'dotenv'

require_relative 'adapters/adapter'

class Coordinator < Sinatra::Base
  Dotenv.load

  # API
  get '/search' do
    unless params[:address]
      error = {errors: [message: 'Please provide a geocodable search query (e.g. an address)']}
      halt 400, {'Content-Type' => 'application/json'}, error.to_json
    else
      Adapter.new(params[:address], params[:provider]).get_coordinates
    end
  end

  # Simple Demo
  get '/' do
    File.read(File.join('public', 'index.html'))
  end

  run! if app_file == $0
end

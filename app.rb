require 'sinatra/base'
require 'dotenv'
require 'pry'

require_relative 'adapters/adapter'

class Coordinator < Sinatra::Base
  Dotenv.load

  mockup_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c'

  # API
  get '/search' do
    if env['HTTP_AUTHORIZATION'] && env['HTTP_AUTHORIZATION'].split(':').last.strip == mockup_token
      unless params[:address]
        error = {errors: [message: 'Please provide a geocodable search query (e.g. an address)']}
        halt 400, {'Content-Type' => 'application/json'}, error.to_json
      else
        Adapter.new(params[:address], params[:provider]).get_coordinates
      end
    else
      error = {errors: [message: 'You are not authorized to use this API.']}
      halt 401, {'Content-Type' => 'application/json'}, error.to_json
    end
  end

  # Simple Demo
  get '/' do
    File.read(File.join('public', 'index.html'))
  end

  run! if app_file == $0
end

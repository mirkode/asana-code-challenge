require 'sinatra/base'
require 'dotenv'

class Coordinator < Sinatra::Base
  Dotenv.load

  run! if app_file == $0
end

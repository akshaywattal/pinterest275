require 'sinatra'
require "json"


class Pinterest < Sinatra::Base
  enable :logging
  #helpers Sinatra::JSON

  before do
    logger.info "Entering Request...."

    if request.request_method == "POST"
      body_parameters = request.body.read
      params.merge!(JSON.parse(body_parameters))
      end

  end

  # User Sign-Up API
  post '/users/signup' do
    content_type :json
    puts "params after post params method = #{params.inspect}"

    #puts request.inspect
    firstName = params[:firstName]
    lastName = params[:lastName]
    emailId = params[:emailId]
    password = params[:password]

    password
  end

  after do
    logger.info "Leaving Request...."
  end

end
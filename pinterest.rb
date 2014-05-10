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

    user = User.new
    user.firstName = params[:firstName]
    user.lastName = params[:lastName]
    user.emailId = params[:emailId]
    user.password = params[:password]

    #{:firstName => user.firstName }.to_json

    links = Link.new
    links.url = "/users/login/"
    links.method = "POST"

    {:links => [{:url => links.url, :method => links.method}]}.to_json

  end

  after do
    logger.info "Leaving Request...."
  end

end
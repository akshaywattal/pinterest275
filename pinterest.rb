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

    links = Link.new
    links.url = "/users/login/"
    links.method = "POST"

    # Persist to database

    # Creating Response Links
    {:links => [{:url => links.url, :method => links.method}]}.to_json
  end

  # User Log-In API
  post '/users/login' do
    content_type :json
    puts "params after post params method = #{params.inspect}"

    user = User.new
    user.emailId = params[:username]
    user.password = params[:password]

    # Check in database

    # Get User ID
    user_id = "123"

    # Creating Response Links
    links1 = Link.new
    links1.url = "/users/" +  user_id + "/boards/"
    links1.method = "GET"

    links2 = Link.new
    links2.url = "/users/" +  user_id + "/boards/"
    links2.method = "POST"

    {:links => [{:url => links1.url, :method => links1.method}, {:url => links2.url, :method => links2.method}]}.to_json
  end

  after do
    logger.info "Leaving Request...."
  end

end
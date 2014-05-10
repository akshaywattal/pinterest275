#!/bin/env ruby

require 'sinatra'
require 'json'

class Links
  attr_reader :u,:met
  def initialize(u, met)
    @url=u
    @method=met
  end
end


###### Sinatra Part ######

set :port, 8080
set :environment, :production

get '/users/:id/boards' do
  return_message = {}
  if params.has_key?('name')
      return_message[:status] == '201'
      links = %w('URL:users/{UserId}/boards/{boardName} Method:GET')
      links.concat  %w('URL:users/{UserId}/boards/{boardName} Method:PUT')
      links.concat  %w('URL:users/{UserId}/boards/{boardName} Method:DELETE')
      links.concat  %w('URL:users/{UserId}/boards/{boardName}/pins Method:POST')
      return_message[:links] = links
    else
      return_message[:status] = 'Invalid Board. Check the details'
      return_message[:links] = []

  end
  return_message.to_json
end
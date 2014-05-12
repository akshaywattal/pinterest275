require 'sinatra'
require 'couchrest_model'
require 'set'

class Comment < CouchRest::Model::Base
  property :_id, String
  property :text, String
  property :user_id, String
end
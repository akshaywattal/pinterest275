require 'sinatra'
require 'couchrest_model'
require 'set'

SERVER = CouchRest.new
DB     = SERVER.database!('pint')

class Comment < CouchRest::Model::Base
  use_database DB
  property :_id, String
  property :text, String
  property :user_id, String
end
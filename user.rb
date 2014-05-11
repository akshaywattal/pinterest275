require 'sinatra'
require 'couchrest_model'

SERVER = CouchRest.new
DB     = SERVER.database!('pint')

class User < CouchRest::Model::Base

  use_database DB
  property :firstName, String
  property :lastName, String
  property :emailId, String
  property :password, String
  property :_id, String
  property :user_id, String

end
require 'sinatra'
require 'couchrest_model'

file = File.read('./server.json')
config = JSON.parse(file)
node = config["database"]

SERVER = CouchRest.new(node)
DB     = SERVER.database!('pint')

class User < CouchRest::Model::Base

  use_database DB
  property :firstName, String
  property :lastName, String
  property :emailId, String
  property :password, String
  property :_id, String
  property :user_id, String
  property :boards, Set

end
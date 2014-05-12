require 'sinatra'
require 'couchrest_model'
require 'set'

file = File.read('./server.json')
config = JSON.parse(file)
node = config["database"]

SERVER = CouchRest.new(node)
DB     = SERVER.database!('pint')

class Pin < CouchRest::Model::Base
  use_database DB
  property :_id, String
  property :pinName, String
  property :image, String
  #property :_attachments, String
  property :attachments, String
  property :description, String
  property :comments, Set

end
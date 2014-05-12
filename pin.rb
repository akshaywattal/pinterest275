require 'sinatra'
require 'couchrest_model'
require 'set'

SERVER = CouchRest.new
DB     = SERVER.database!('pint')

class Pin < CouchRest::Model::Base
  use_database DB
  property :_id, String
  property :pinName, String
  property :image, String
  property :attachments, String
  property :description, String

end
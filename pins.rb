require 'sinatra'
require 'couchrest_model'
require 'set'

class Pins < CouchRest::Model::Base
  use_database DB
  property :pins, Set
end
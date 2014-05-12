require 'sinatra'
require 'couchrest_model'
require 'set'


class Image < CouchRest::Model::Base
  use_database DB
  property :image_url, String
end
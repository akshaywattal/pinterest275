require 'sinatra'
require 'couchrest_model'
require 'set'


class Boards < CouchRest::Model::Base
  use_database DB

  property :_id, String
  property :boards, Set

end
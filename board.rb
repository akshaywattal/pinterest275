require 'sinatra'
require 'couchrest_model'
require 'set'


class Board < CouchRest::Model::Base
  #attr_accessor :boardName, :boardDesc, :category, :isPrivate
  #use_database DB
  property :boardName, String
  property :boardDesc, String
  property :category, String
  property :isPrivate, String, :default => "false"
  property :pins, Set
end
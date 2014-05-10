require 'sinatra'
require 'data_mapper' # metagem, requires common plugins too.

# need install dm-sqlite-adapter
#DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/blog.db")

class User
 include DataMapper::Resource
 # property :id, Integer
  property :firstName, String
 # property :lastName, String
#  property :emailId, String
 # property :password, String
end

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
#DataMapper.finalize
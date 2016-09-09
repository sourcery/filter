require 'active_record'
require 'sequel'
require './spec/models/widget'

uri = URI(ENV['DATABASE_URL'])
DB = Sequel.connect(ENV['DATABASE_URL'])
CONNECTION = Sequel.connect(ENV['DATABASE_URL'].gsub(/\/[^\/]+$/, ''))

ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  host: uri.host,
  username: uri.user,
  password: uri.password,
  port: uri.port,
  database: uri.path[1..-1]
)

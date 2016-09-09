require 'dotenv'
Dotenv.load
ENV['DATABASE_URL'] = ENV['TEST_DATABASE_URL']


require 'filter'
require './spec/models'

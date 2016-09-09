#!/usr/bin/env ruby

require "bundler/setup"
require 'dotenv'
Dotenv.load
require "sequel"
require "filter"
require "./spec/models"

def drop?
  ARGV.include?('--drop')
end

def execute_sql(db, sql)
  db[sql]
end

def db_exists?(db, dbname)
  execute_sql(db, "SELECT 'exists' FROM pg_database WHERE datname = '#{dbname}'").to_a.flatten.any?
end

[ ENV['DATABASE_URL'], ENV['TEST_DATABASE_URL'] ].each do |url|
  uri = URI(url)
  url_without_path = url.gsub(/\/[^\/]+$/, '')
  name = uri.path[1..-1]

  db = Sequel.connect(url_without_path)

  db["DROP DATABASE \"#{name}\""].to_a if db_exists?(db, name) && drop?
  db["CREATE DATABASE \"#{name}\""].to_a unless db_exists?(db, name)

  `sequel -m spec/migrate #{url}`
end

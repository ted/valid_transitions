$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require 'active_record'
require 'pry'
require "minitest/autorun"
require "valid_transitions"



ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

load File.dirname(__FILE__) + '/schema.rb'
require File.dirname(__FILE__) + '/models/car.rb'



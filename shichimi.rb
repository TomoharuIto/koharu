require 'twitter'
require 'net/http'
require 'uri'
require 'json'
require 'pp'

keys = File.open("data.json")
client = Twitter::REST::Client.new(keys)
pp client

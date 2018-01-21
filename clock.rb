require 'clockwork'
require 'date'
require 'dotenv'
require 'json'
require 'net/http'
require 'twitter'
require 'uri'
# require 'pp'

Dotenv.load
client_rest = Twitter::REST::Client.new(
  consumer_key: ENV['CONSUMER_KEY'],
  consumer_secret: ENV['CONSUMER_SECRET'],
  access_token: ENV['ACCESS_TOKEN'],
  access_token_secret: ENV['ACCESS_TOKEN_SECRET']
)

# Thanks!
# Weather forecast API provided by Weather Hacks
# http://weather.livedoor.com/weather_hacks/webservice

module Inquiry
  def call(i)
    path = "http://weather.livedoor.com/forecast/webservice/json/v1?city=#{i}"
    uri = URI.parse(path)
    json = Net::HTTP.get(uri)
    JSON.parse(json)
  end
end

include Inquiry
area = call(200010)
public_time = area['description']['publicTime']
date_time = DateTime.parse(public_time)
suffix = %w(お を の もふ よ ぽ と)
announcement_time = date_time.strftime("%m月%d日 %H時%M分 発表の予報です#{suffix.sample}。\n\n")
weather = area['description']['text']
weather_forecast = (announcement_time << weather).scan(/.{1,139}。/m).reverse

include Clockwork
every(1.day, 'koharu', :at => '06:00') do
  weather_forecast.each do |par|
    client_rest.update(par)
  end
end


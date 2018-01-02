require 'twitter'
require 'net/http'
require 'uri'
require 'json'
require 'date'
require 'clockwork'
require 'pp'
require 'dotenv'

Dotenv.load
client_rest = Twitter::REST::Client.new(
  consumer_key: ENV['CONSUMER_KEY'],
  consumer_secret: ENV['CONSUMER_SECRET'],
  access_token: ENV['ACCESS_TOKEN'],
  access_token_secret: ENV['ACCESS_TOKEN_SECRET']
)

client_streaming = Twitter::Streaming::Client.new(
  consumer_key: ENV['CONSUMER_KEY'],
  consumer_secret: ENV['CONSUMER_SECRET'],
  access_token: ENV['ACCESS_TOKEN'],
  access_token_secret: ENV['ACCESS_TOKEN_SECRET']
)

module Inquiry
  def call(i)
    path = "#{self}#{i}"
    uri = URI.parse(path)
    json = Net::HTTP.get(uri)
    JSON.parse(json)
  end
end

# Weather report API provided by Weather Hacks
# http://weather.livedoor.com/weather_hacks/webservice

weather_info = "http://weather.livedoor.com/forecast/webservice/json/v1?city="
include Inquiry
north = weather_info.call(200010)
central = weather_info.call(200020)
south = weather_info.call(200030)
region = north['pinpointLocations']|central['pinpointLocations']|south['pinpointLocations']

# place = "動物園の街＃須坂市にははカピバラさんがいます。"
# place.match(%r|\s?[#＃]\s?(.+)\z|)
# ps = $1
# location_match = region.select{|area| ps =~ Regexp.compile(area['name'])}
# place = location_match[0].fetch("name")
# link = location_match[0].fetch("link")
# pp place
# pp link

client_streaming.user do |status|
  case status
  when Twitter::DirectMessage
    str = status.full_text.match(%r|\s?[#＃]\s?(.+)\z|)
    location = $1
    name = status.sender.screen_name
    location_match = region.select{|area| location =~ Regexp.compile(area['name'])}
    place = location_match[0].fetch("name")
    link = location_match[0].fetch("link")
    if(location_match) # && (status.sender.id != 932259721318297600)
      client_rest.create_direct_message(status.sender.id, "#{name}さん、#{place}の天気へのリンクは#{link}です。")
    elsif(!location_match)
      client_rest.create_direct_message(status.sender.id, "位置情報を取得できませんでした。")
    elsif(status.full_text =~ /ping/)
      client_rest.create_direct_message(status.sender.id, "PONG")
    end
  end
end

# public_time = central['description']['publicTime']
# date_time = DateTime.parse(public_time)
# suffix = %w(お を の もふ よ ぽ と)
# announcement_time = date_time.strftime("%m月%d日 %H時%M分 発表の予報です#{suffix.sample}。\n\n")
# weather = central['description']['text']
# weather_forecast = (announcement_time << weather).scan(/.{1,139}。/m).reverse
#
# include Clockwork
# every(1.day, 'shichimi', :at => '06:00') do
#   weather_forecast.each do |par|
#     client_rest.update(par)
#   end
# end

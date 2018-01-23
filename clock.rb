require 'clockwork'
require 'date'
require 'dotenv'
require 'json'
require 'net/http'
require 'twitter'
require 'uri'
require 'pp'

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
north = call(200010)
central = call(200020)
south = call(200030)
module Weather
  def forecast(area, i)
    include Inquiry
    weather = area['forecasts']
    date = weather[i]['dateLabel']
    date_time = weather[i]['date']
    time = DateTime.parse(date_time)
    announcement_time = time.strftime("%m月%d日")
    telop = weather[i]['telop']
    image = weather[i]['image']['url']
#     num = image.match(/\/(\d+)\./).to_s
    num = image.delete("^0-9")
    emoji = num.gsub(num, "9" => "Hello", "11" => "\u{2603}\/\u{2601}")
    pp emoji
    temperature_max = weather[i]['temperature']['max']
    unless temperature_max == nil
      temperature_max = temperature_max['celsius']
    else
      temperature_max = "-"
    end
    temperature_min = weather[i]['temperature']['min']
    unless temperature_min == nil
      temperature_min = temperature_min['celsius']
    else
      temperature_min = "-"
    end
    weather_forecast = "#{date}: #{announcement_time}\n天気: #{telop}\n気温: 最高#{temperature_max}℃ 最低#{temperature_min}℃\n\n"
  end
end
include Weather
north_weather = "北部\n" + forecast(north, 0)<<forecast(north, 1)<<forecast(north, 2)
central_weather ="中部\n" +  forecast(central, 0)<<forecast(central, 1)<<forecast(central, 2)
south_weather = "南部\n" + forecast(south, 0)<<forecast(south, 1)<<forecast(south, 2)
region_weather = ["#{north_weather}", "#{central_weather}", "#{south_weather}"].reverse
pp region_weather
# region_weather.each do |par|
#   client_rest.update(par)
# end


region = north['pinpointLocations']|central['pinpointLocations']|south['pinpointLocations']
public_time = central['description']['publicTime']
date_time = DateTime.parse(public_time)
suffix = %w(お を の もふ よ ぽ と)
announcement_time = date_time.strftime("%m月%d日 %H時%M分 発表の予報です#{suffix.sample}。\n\n")
weather = central['description']['text']
weather_forecast = (announcement_time << weather).scan(/.{1,139}。/m).reverse

# include Clockwork
# every(1.day, 'shichimi', :at => '11:05') do
#   weather_forecast.each do |par|
#     client_rest.update(par)
#   end
# end


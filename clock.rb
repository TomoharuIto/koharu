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
  begin
  def forecast(area, i)
    include Inquiry
    weather = area['forecasts']
    city = area['location']['city']
    link = area['link']
    date = weather[i]['dateLabel']
    date_time = weather[i]['date']
    time = DateTime.parse(date_time)
    announcement_time = time.strftime("%m月%d日")
    telop = weather[i]['telop']
    image = weather[i]['image']['url']
    num = image.delete("^0-9")
    emoji = num.gsub(num, "1" => "\u{2600 FE0F}", "2" => "\u{2600 FE0F}\/\u{2601 FE0F}", "3" => "\u{2600 FE0F}\/\u{2602 FE0F}",
    "4" => "\u{2600 FE0F}\/\u{26C4 FE0F}", "5" => "\u{2600 FE0F}→\u{2601 FE0F}", "6" => "\u{2600 FE0F}→\u{2602 FE0F}",
    "7" => "\u{2600 FE0F}→\u{26C4 FE0F}", "8" => "\u{2601 FE0F}", "9" => "\u{2601 FE0F}\/\u{2600 FE0F}",
    "10" => "\u{2601 FE0F}\/\u{2602 FE0F}", "11" => "\u{2601 FE0F}\/\u{26C4 FE0F}", "12" => "\u{2601 FE0F}→\u{2600 FE0F}",
    "13" => "\u{2601 FE0F}→\u{26C4 FE0F}", "14" => "\u{2601 FE0F}→\u{26C4 FE0F}", "15" => "\u{2602 FE0F}",
    "16" => "\u{2602 FE0F}\/\u{2600 FE0F}", "17" => "\u{2602 FE0F}\/\u{2601 FE0F}", "18" => "\u{2602 FE0F}\/\u{26C4 FE0F}",
    "19" => "\u{2602 FE0F}→\u{2600 FE0F}", "20" => "\u{2602 FE0F}→\u{2601 FE0F}", "21" => "\u{2602 FE0F}→\u{26C4 FE0F}",
    "22" => "\u{2614 FE0F}", "23" => "\u{26C4 FE0F}", "24" => "\u{26C4 FE0F}\/\u{2600 FE0F}", "25" => "\u{26C4 FE0F}\/\u{2601 FE0F}",
    "26" => "\u{26C4 FE0F}\/\u{2602 FE0F}", "27" => "\u{26C4 FE0F}→\u{2600 FE0F}", "28" => "\u{26C4 FE0F}→\u{2601 FE0F}",
    "29" => "\u{26C4 FE0F}→\u{2602 FE0F}", "30" => "\u{2603 FE0F}")
    temperature_max = weather[i]['temperature']['max']
    unless temperature_max == nil
      temperature_max = temperature_max['celsius']
    else
      temperature_max = "--"
    end
    temperature_min = weather[i]['temperature']['min']
    unless temperature_min == nil
      temperature_min = temperature_min['celsius']
    else
      temperature_min = "--"
    end
    weather_forecast = "地域: #{city}\n#{date}: #{announcement_time}\n天気: #{telop}#{emoji}\n気温: 最高#{temperature_max}℃ 最低#{temperature_min}℃\nlink: #{link}\n"
  rescue
    weather_forecast ||= ""
  end
  end
end

include Weather
today_north_weather = forecast(north, 0)
today_central_weather = forecast(central, 0)
today_south_weather = forecast(south, 0)
today_region_weather = ["#{today_north_weather}", "#{today_central_weather}", "#{today_south_weather}"].reverse

tomorrow_north_weather = forecast(north, 1) << forecast(north, 2)
tomorrow_central_weather = forecast(central, 1) << forecast(central, 2)
tomorrow_south_weather = forecast(south, 1) << forecast(south, 2)
tomorrow_region_weather = ["#{tomorrow_north_weather}", "#{tomorrow_central_weather}", "#{tomorrow_south_weather}"].reverse

public_time = central['description']['publicTime']
date_time = DateTime.parse(public_time)
suffix = %w(お を の もふ よ ぽ と)
prefix = %w()
announcement_time = date_time.strftime("%m月%d日 %H時%M分 発表の予報です#{suffix.sample}。\n\n")
weather = central['description']['text'].gsub(/\s|。/,"/s" => "", "。" => "。\n\n")
weather_forecast = (announcement_time << weather).scan(/.{1,139}\n/m).reverse

# include Clockwork
# every(1.day, 'morning', :at => '06:00') do
#   today_region_weather.each do  |par|
#     client_rest.update(par)
#   end
#  end
#
# every(1.day, 'noon', :at => '12:00') do
#   weather_forecast.each do |par|
#     client_rest.update(par)
#   end
# end
#
# every(1.day, 'evening', :at => '18:00') do
#   tomorrow_region_weather.each do  |par|
#     client_rest.update(par)
#   end
#  end

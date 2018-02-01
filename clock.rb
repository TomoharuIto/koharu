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

    face = [
      "\u{1F600 FE0F}", "\u{1F601 FE0F}", "\u{1F602 FE0F}", "\u{1F603 FE0F}", "\u{1F604 FE0F}", "\u{1F605 FE0F}", "\u{1F606 FE0F}", "\u{1F607 FE0F}",
      "\u{1F608 FE0F}", "\u{1F609 FE0F}", "\u{1F60A FE0F}", "\u{1F60B FE0F}", "\u{1F60C FE0F}", "\u{1F60D FE0F}", "\u{1F60E FE0F}", "\u{1F60F FE0F}"
        ]

    begin
      temperature_max = weather[i]['temperature']['max']['celsius']
      temperature_min = weather[i]['temperature']['min']['celsius']
    rescue
      temperature_max ||= "#{face.sample}"
      temperature_min ||= "#{face.sample}"
    end
    weather_forecast = "#{date}: #{announcement_time}\n天気: #{telop}#{emoji}\n気温: 最高#{temperature_max}℃ 最低#{temperature_min}℃\n\n"
  rescue
    weather_forecast ||= ""
  end
  end
end

include Weather

north_link = north['link']
central_link = central['link']
south_link = south['link']

north_city = north['location']['city']
central_city = central['location']['city']
south_city = south['location']['city']


today_north_weather = "北部: #{north_city}市\n\n" << forecast(north, 0) << "Link: #{north_link}"
today_central_weather = "中部: #{central_city}市\n\n" << forecast(central, 0) << "Link: #{central_link}"
today_south_weather = "南部: #{south_city}市\n\n" << forecast(south, 0) << "Link: #{south_link}"
today_region_weather = ["#{today_north_weather}", "#{today_central_weather}", "#{today_south_weather}"].reverse

tomorrow_north_weather = "北部: #{north_city}市\n\n" << forecast(north, 1) << forecast(north, 2) << "Link: #{north_link}"
tomorrow_central_weather = "中部: #{central_city}市\n\n" << forecast(central, 1) << forecast(central, 2) << "Link: #{central_link}"
tomorrow_south_weather = "南部: #{south_city}市\n\n" << forecast(south, 1) << forecast(south, 2) << "Link: #{south_link}"
tomorrow_region_weather = ["#{tomorrow_north_weather}", "#{tomorrow_central_weather}", "#{tomorrow_south_weather}"].reverse

date = Date.today
weeks = %w(日 月 火 水 木 金 土)
today = "#{date.month}月#{date.day}日#{weeks[date.wday]}曜日,お昼の天気予報をお伝えします。\n"
excuse = %w(ごめ～ん、文字数オーバーしちゃった。 わ～、文字数超過しちゃいました。 ごめんなさい、文字数オーバーのようです。)
weather = central['description']['text'].gsub(/\s|。/,"\s" => "", "。" => "。\n")
weather_forecast = (today << weather).scan(/^\d+.+?\D+$/m).reverse

include Clockwork
every(1.day, 'morning', :at => '7:00') do
  today_region_weather.each do  |par|
    begin
      client_rest.update(par)
    rescue
      client_rest.update("#{excuse.sample}")
    end
  end
 end

every(1.day, 'noon', :at => '13:00') do
  weather_forecast.each do |par|
    begin
      client_rest.update(par)
    rescue
      client_rest.update("#{excuse.sample}")
    end
  end
end

every(1.day, 'evening', :at => '18:00') do
  tomorrow_region_weather.each do  |par|
    begin
      client_rest.update(par)
    rescue
      client_rest.update("#{excuse.sample}")
    end
  end
 end

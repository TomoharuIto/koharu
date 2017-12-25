require 'twitter'
require 'net/http'
require 'uri'
require 'json'
require 'date'
require 'clockwork'
require 'pp'

h = File.open("data.json"){|f| JSON.load(f)}
keys = h[0]
client_rest = Twitter::REST::Client.new(keys)
# client_streaming = Twitter::Streaming::Client.new(keys)

uri_nagano = URI.parse('http://weather.livedoor.com/forecast/webservice/json/v1?city=200010')
uri_matsumoto = URI.parse('http://weather.livedoor.com/forecast/webservice/json/v1?city=200020')
uri_iida = URI.parse('http://weather.livedoor.com/forecast/webservice/json/v1?city=200030')
json = Net::HTTP.get(uri_matsumoto)
result = JSON.parse(json)
public_time = result['description']['publicTime']
date_time = DateTime.parse(public_time)
suffix = %w(お を の もふ よ ぽ と)
announcement_time = date_time.strftime("%m月%d日 %H時%M分 発表の予報です#{suffix.sample}。\n\n")
weather = result['description']['text']
weather_forecast = (announcement_time << weather).scan(/.{1,139}。$/m).reverse
pp weather_forecast
# include Clockwork
#   every(1.day, 'shichimi', :at => '06:00') do
    weather_forecast.each do |par|
      client_rest.update(par)
    end
#   end

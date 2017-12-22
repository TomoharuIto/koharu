require 'twitter'
require 'net/http'
require 'uri'
require 'json'
require 'date'
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
suffix = ["お", "を", "の", "もふ", "よ", "のよ", "と",]
announcement_time = date_time.strftime("%m月%d日 %H:%M 発表の長野県内の気象情報です#{suffix.sample}。\n\n")
weather_forecast = result['description']['text']
announcing = (announcement_time << weather_forecast).scan(/.{1,139}。$/m).reverse
announcing.each do |par|
  client_rest.update(par)
end

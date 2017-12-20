require 'twitter'
require 'net/http'
require 'uri'
require 'json'
require 'pp'

h = File.open("data.json"){|f| JSON.load(f)}
keys = h[0]
client_rest = Twitter::REST::Client.new(keys)
client_streaming = Twitter::Streaming::Client.new(keys)

uri_nagano = URI.parse('http://weather.livedoor.com/forecast/webservice/json/v1?city=200010') # 長野
uri_matsumoto = URI.parse('http://weather.livedoor.com/forecast/webservice/json/v1?city=200020') # 松本
uri_iida = URI.parse('http://weather.livedoor.com/forecast/webservice/json/v1?city=200030') # 飯田
json = Net::HTTP.get(uri_matsumoto)
result = JSON.parse(json)
pp result['description']['text']


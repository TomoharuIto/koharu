require 'clockwork'
require 'date'
require 'docomoru'
require 'dotenv'
require 'json'
require 'net/http'
require 'twitter'
require 'uri'
# require 'pp'

# Thanks!
# Weather forecast API provided by Weather Hacks
# http://weather.livedoor.com/weather_hacks/webservice
# Dialogue API provided by docomo Developer support
# https://dev.smt.docomo.ne.jp/?p=index

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

client_docomo = Docomoru::Client.new(
  api_key: ENV['DOCOMO_API_KEY']
)

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
region = north['pinpointLocations']|central['pinpointLocations']|south['pinpointLocations']

own = client_rest.user(client_rest.verify_credentials.id)
own_id = own.id

client_streaming.user do |status|
  if status.is_a?(Twitter::DirectMessage) && (status.sender.id != own_id)
    hashtag = status.full_text.match(%r|\s?[#＃]\s?(.{1,5})\s?|)
    dest = status.sender.id
    if(!hashtag.nil?)
      location = $1
      location_match = region.select{|area| Regexp.compile(area['name']) =~ location}
      if(!location_match.empty?)
        name = status.sender.screen_name
        place = location_match[0].fetch("name")
        link = location_match[0].fetch("link")
        client_rest.create_direct_message(dest, "#{name}さん、#{place}の天気へのリンクはこちらです。\n#{link}")
      elsif(location_match.empty?)
        client_rest.create_direct_message(dest, "位置情報を取得できませんでした。")
      end
    elsif(hashtag.nil?)
      if(status.full_text =~ /ping/)
        client_rest.create_direct_message(dest, "PONG")
      else
        talk = client_docomo.create_dialogue(status.full_text)
        response = talk.body['utt']
        client_rest.create_direct_message(dest, "#{response}")
      end
    end
  end
end

public_time = central['description']['publicTime']
date_time = DateTime.parse(public_time)
suffix = %w(お を の もふ よ ぽ と)
announcement_time = date_time.strftime("%m月%d日 %H時%M分 発表の予報です#{suffix.sample}。\n\n")
weather = central['description']['text']
weather_forecast = (announcement_time << weather).scan(/.{1,139}。/m).reverse

include Clockwork
every(1.day, 'shichimi', :at => '06:00') do
  weather_forecast.each do |par|
    client_rest.update(par)
  end
end

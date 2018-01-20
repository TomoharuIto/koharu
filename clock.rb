require File.expand_path('../bot', __FILE__)

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


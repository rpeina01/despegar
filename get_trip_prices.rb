require 'net/http'
require 'colorize'
require 'json'
require 'yaml'
require './Trip.rb'
require './lib/extensions.rb'

require 'optparse'

options = YAML.load_file('config.yml')
puts options
OptionParser.new do |opts|
  opts.banner = "Usage: despegar.rb [options]"
  opts.on("-c", "--city city", "City code") { |v| options['city_code'] = v.to_s.upcase }
  opts.on("-d", "--duration days", "Duration in days") { | v |  options['duration_in_days'] = v.to_i }
end.parse!

p options
options.freeze

one_day  = 60 * 60 * 24
margin   = 2
from     = Time.utc(2016,10,6)
end_date = Time.utc(2016,12,31)
to       = from + options['duration_in_days']

output = "results/output_#{Time.now.to_i}.csv"
File.open(output, 'w') { |file| file.write('from day;from month;from year;to day;to month;to year;cost') }
from -= one_day
while to <= end_date
    to   = from + options['duration_in_days'] * one_day
    from += one_day
    to_aux = (to-one_day*margin)
    threads = []
    while to_aux <= (to+one_day*margin)
        trip = Trip.new('MIA', from, to_aux)
        puts trip.base_url
        trip.base_url = 'http://www.despegar.cl/shop/flights/data/search/roundtrip/scl/'
        puts trip.base_url
        # threads.push(Thread.new(to_aux){ |to_aux|
        #     url = "http://www.despegar.cl/shop/flights/data/search/roundtrip/scl/#{options['city']}/#{from.year}-#{from.month}-#{from.day}/#{to_aux.year}-#{to_aux.month}-#{to_aux.day}/1/0/0/TOTALFARE/ASCENDING/NA/NA/NA/NA/NA"
        #     uri = URI(url)
        #     response = Net::HTTP.get(uri)
        #     json = JSON.parse(response)
        #     price = json["result"]["data"]["items"].first["emissionPrice"]["total"]["fare"]["raw"]
        #     price_output = price.formatWithPoints
        #
        #     if price >= options['price_ranges']['excessive']
        #         price_output = price_output.red
        #     elsif price >= options['price_ranges']['expensive']
        #         price_output = price_output.light_red
        #     elsif price >= options['price_ranges']['moderate']
        #         price_output = price_output.yellow
        #     elsif price >= options['price_ranges']['moderate_to_cheap']
        #         price_output = price_output.light_yellow
        #     elsif price >= options['price_ranges']['cheap']
        #         price_output = price_output.green
        #     else
        #         price_output = price_output.light_green
        #     end
        #
        #     puts "#{from.day}/#{from.month} to #{to_aux.day}/#{to_aux.month}: #{price_output}"
        #
        #     File.open(output, 'a') {|file|
        #         file.write "#{from.day};#{from.month};#{from.year};#{to_aux.day};#{to_aux.month};#{to_aux.year};" + json["result"]["data"]["items"].first["emissionPrice"]["total"]["fare"]["raw"].to_s + "\n"
        #     }
        # })

        to_aux += one_day
    end
    threads.each do | thread |
        thread.join
    end
    puts
end

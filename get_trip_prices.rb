require 'net/http'
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
# from -= one_day
# from = from.tomorrow
from = from.yesterday
while to <= end_date
    to   = from.addDays(options['duration_in_days'])
    from = from.tomorrow
    to_aux = to.substractDays(margin)
    threads = []
    (0..margin).each do | margin |
        trip = Trip.new('MIA', from, to.addDays(margin))
        trip.base_url = 'http://www.despegar.cl/shop/flights/data/search/roundtrip/scl/'
        trip.setRanges(options['price_ranges'])
        json = trip.getData
        price = trip.getLowestPrice
        price_output = price.formatWithPoints

        puts trip

        File.open(output, 'a') {|file|
            file.write "#{from.day};#{from.month};#{from.year};#{to_aux.day};#{to_aux.month};#{to_aux.year};" + json["result"]["data"]["items"].first["emissionPrice"]["total"]["fare"]["raw"].to_s + "\n"
        }
    end
    puts
end

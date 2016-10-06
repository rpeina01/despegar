require 'net/http'
require 'json'
require 'yaml'
require './Trip.rb'
require './lib/extensions.rb'
require './lib/modules/logger.rb'
require './lib/modules/opts_validator.rb'

require 'optparse'

options = YAML.load_file('config.yml')
puts options
OptionParser.new do |opts|
  opts.banner = "Usage: despegar.rb [options]"
  opts.on("-c", "--city city", "City code") { |v| options[:city] = v.to_s.upcase }
  opts.on("-d", "--duration days", "Duration in days") { | v |  options[:duration_in_days] = v.to_i }
end.parse!

p options
options.freeze

logger = CustomLogger::getLog(STDOUT, Logger::INFO)
options_validator = OptsValidator.new(options, logger)
options_validator.validate_presence_of(:city, 'destination city code', 'c')
options_validator.validate_presence_of(:duration_in_days, 'duration in days', 'd')
logger.info("Destination city code: #{options[:city].upcase}")

margin   = 2
from     = Time.utc(2016,10,6)
end_date = Time.utc(2016,12,31)
to       = from + options[:duration_in_days]

output = "results/output_#{Time.now.to_i}.csv"
File.open(output, 'w') { |file| file.write('from day;from month;from year;to day;to month;to year;cost') }
from = from.yesterday
while to <= end_date
    to   = from.addDays(options[:duration_in_days])
    from = from.tomorrow
    to_aux = to.substractDays(margin)
    threads = []
    (0..margin).each do | margin |
        trip = Trip.new(options[:city], from, to.addDays(margin))
        trip.base_url = 'http://www.despegar.cl/shop/flights/data/search/roundtrip/scl/'
        trip.setRanges(options['price_ranges'])
        json = trip.getData
        price = trip.getLowestPrice.formatWithPoints
        puts trip
        File.open(output, 'a') {|file|
            file.write "#{trip.start_date.day};#{trip.start_date.month};#{trip.start_date.year};#{trip.end_date.day};#{trip.end_date.month};#{trip.end_date.year};" + price + "\n"
        }
    end
    puts
end

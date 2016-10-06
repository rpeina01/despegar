require 'fileutils'
require 'json'
require 'net/http'
require 'yaml'
require './Trip.rb'
require './lib/extensions.rb'
require './lib/modules/logger.rb'
require './lib/modules/opts_validator.rb'
require 'optparse'

response = FileUtils.mkdir_p('results')

options = YAML.load_file('config.yml')
puts options
OptionParser.new do |opts|
  opts.banner = "Usage: despegar.rb [options]"
  opts.on("-f", "--origin-city origin-city", "origin city code") { |v| options[:origin_city] = v.to_s.upcase }
  opts.on("-t", "--destination-city destination-city", "Destination city code") { |v| options[:destination_city] = v.to_s.upcase }
  opts.on("-d", "--duration days", "Duration in days") { | v |  options[:duration_in_days] = v.to_i }
  opts.on("--debug", "--debug", "Activate debug") { | v |  options[:debug] = true }
end.parse!

p options
options.freeze

logger = CustomLogger::getLog(STDOUT, Logger::INFO)
options_validator = OptsValidator.new(options, logger)
options_validator.validate_presence_of(:origin_city, 'destination city code', 'f')
options_validator.validate_presence_of(:destination_city, 'destination city code', 't')
options_validator.validate_presence_of(:duration_in_days, 'duration in days', 'd')
logger.warn("Using debug mode") if options[:debug]
logger.info("Origin city code: #{options[:origin_city].upcase}")
logger.info("Destination city code: #{options[:destination_city].upcase}")

margin   = 2
from     = Time.utc(2016,10,6)
end_date = Time.utc(2016,12,31)
to       = from + options[:duration_in_days]

output = "results/#{options[:origin_city]}_#{options[:destination_city]}_#{from.strftime('%d_%b_%Y')}_to_#{end_date.strftime('%d_%b_%Y')}_#{Time.now.to_i}.csv".downcase
File.open(output, 'w') { |file| file.write('from day;from month;from year;to day;to month;to year;cost') }

date_format = '%d %b'
from = from.yesterday
trip = Trip.new(options[:origin_city], options[:destination_city])
trip.base_url = 'http://www.despegar.cl/shop/flights/data/search/roundtrip/'
trip.debug = true if options[:debug]
trip.setRanges(options['price_ranges'])
while to <= end_date
    from = from.tomorrow
    to   = from.addDays(options[:duration_in_days])
    to_aux = to.substractDays(margin)
    threads = []
    puts "From: ".blue + "#{to.strftime(date_format)}".light_blue
    (-margin..margin).each do | margin |
        current_to = to.addDays(margin)
        trip.start_date = from
        trip.end_date = current_to
        json = trip.getData
        price = trip.getLowestPrice.formatWithPoints
        puts "\t- To ".blue + "#{current_to.strftime(date_format)}:".light_blue + " #{trip.getLowestPriceWithColor}"
        File.open(output, 'a') {|file|
            file.write "#{trip.start_date.day};#{trip.start_date.month};#{trip.start_date.year};#{trip.end_date.day};#{trip.end_date.month};#{trip.end_date.year};" + price + "\n"
        }
    end
    puts
end

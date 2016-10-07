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
OptionParser.new do |opts|
  opts.banner = "Usage: despegar.rb [options]"
  opts.on("-f", "--origin-city origin-city", "origin city code") { |v| options[:origin_city] = v.to_s.upcase }
  opts.on("-t", "--destination-city destination-city", "Destination city code") { |v| options[:destination_city] = v.to_s.upcase }
  opts.on("-d", "--duration days", "Duration in days") { | v |  options[:duration_in_days] = v.to_i }
  opts.on("-m", "--margin margin-in-days", "Margin in days") { | v |  options['margin'] = v.to_i }
  opts.on("-n", "--threads number-of-threads", "Number of threads") { | v |  options['number_of_threads'] = v.to_i }
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

from     = Time.utc(2016,12,31)
end_date = Time.utc(2017,07,31)
to       = from + options[:duration_in_days]

output = "results/#{options[:origin_city]}_#{options[:destination_city]}_#{from.strftime('%d_%b_%Y')}_to_#{end_date.strftime('%d_%b_%Y')}_#{Time.now.to_i}.csv".downcase
File.open(output, 'w') { |file| file.write("From day;From month;From year;To day;To month;To year;Price\n") }

date_format = '%d %b'
from = from.yesterday
threads = []
while to <= end_date
    from = from.tomorrow
    to   = from.addDays(options[:duration_in_days])
    puts "From: ".blue + "#{from.strftime(date_format)}".light_blue
    (-options['margin']..options['margin']).each do | margin |
        current_to = to.addDays(margin)
        threads.push << Thread.new(from, current_to){ | from, to |
            trip = Trip.new(options[:origin_city], options[:destination_city])
            trip.base_url = 'http://www.despegar.cl/shop/flights/data/search/roundtrip/'
            trip.debug = true if options[:debug]
            trip.setRanges(options['price_ranges'])
            trip.start_date = from
            trip.end_date = current_to
            json = trip.getData
            price = trip.getLowestPrice.formatWithPoints
            puts "\t- To ".blue + "#{current_to.strftime(date_format)}:".light_blue + " #{trip.getLowestPriceWithColor}"
            File.open(output, 'a') {|file|
                file.write "#{trip.start_date.day};#{trip.start_date.month};#{trip.start_date.year};#{trip.end_date.day};#{trip.end_date.month};#{trip.end_date.year};" + price + "\n"
            }
        }
        threads.each { | thread | thread.join } and threads = [] if threads.count == options['number_of_threads']
    end
    threads.each { | thread | thread.join }
    threads = []
    puts
end
threads.each { | thread | thread.join }

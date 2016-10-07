require 'fileutils'
require 'json'
require 'net/http'
require 'yaml'
require './Trip.rb'
require './lib/extensions.rb'
require './lib/modules/logger.rb'
require './lib/modules/opts_validator.rb'
require 'optparse'
require 'ruby-progressbar'

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
  opts.on("-a", "--auto-colorize", "Auto colorize prices") { | v |  options[:auto_colorize] = true }
  opts.on("-u", "--hide-partial-output", "Hice partial output") { | v |  options[:hide_partial_output] = true }
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

from     = Time.utc(2016,12,1)
end_date = Time.utc(2016,12,31)
# end_date = Time.utc(2017,03,15)
to       = from + options[:duration_in_days]

output = "results/#{options[:origin_city]}_#{options[:destination_city]}_#{from.strftime('%d_%b_%Y')}_to_#{end_date.strftime('%d_%b_%Y')}_#{Time.now.to_i}.csv".downcase
File.open(output, 'w') { |file| file.write("From day;From month;From year;To day;To month;To year;Price\n") }

date_format = '%d %b'
from = from.yesterday
threads = []
results = {}
displayResults = -> (from_str, from_data) {
    my_from = Date.parse(from_str)
    puts "From: ".blue + "#{my_from.strftime(date_format)}".light_blue
    from_data = from_data.sort_by { | to_str, price | to_str }
    from_data.each do | to_str, price |
        my_current_to = Date.parse(to_str)
        puts "\tto #{my_current_to.strftime(date_format)}: ".light_blue + price
    end
}
all_results = {}
progressbar = ProgressBar.create
difference_in_days = (end_date - to).to_i / (24 * 60 * 60)
days_elapsed = 0
while to <= end_date
    progressbar.progress = ((days_elapsed.to_f / difference_in_days.to_f) * 100).to_i
    days_elapsed += 1
    from = from.tomorrow
    to   = from.addDays(options[:duration_in_days])
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
            results[ from.to_s ] ||= {}
            all_results[ from.to_s ] ||= {}
            results[ from.to_s ][ current_to.to_s ]     = trip.getLowestPriceWithColor
            all_results[ from.to_s ][ current_to.to_s ] = trip.getLowestPrice
        }
    end
    threads.each { | thread |
        thread.join
    }
    if not options[:hide_partial_output] and threads.count >= options['number_of_threads']
        results = results.sort_by { | to_str, price | to_str }
        results.each &displayResults
        threads = []
        results = {}
    end
end
threads.each { | thread | thread.join }
if not options[:hide_partial_output]
    results = results.sort_by { | to_str, price | to_str }
    results.each &displayResults
end

prices = all_results.map { | date_date, values | values.map { | from_date, price | price } }.flatten
puts "Mean: #{prices.mean}"

ranges = {
    excessive: percentile(prices, 0.90),
    expensive: percentile(prices, 0.75),
    moderate: percentile(prices, 0.50),
    moderate_to_cheap: percentile(prices, 0.35),
    cheap: percentile(prices, 0.25)
}

if options[:auto_colorize]
    puts "Colorize:"
    # all_results.each { | date_from, values |
    #     from = Date.parse(date_from)
    #     values.each { | date_to, price |
    #         to = Date.parse(date_to)
    #         puts to.to_s
    #         puts price
    #     }
    # }
    all_results = all_results.sort_by { | to_str, price | to_str }
    all_results.each { | from_str, from_data |
        my_from = Date.parse(from_str)
        puts "From: ".blue + "#{my_from.strftime(date_format)}".light_blue
        from_data = from_data.sort_by { | to_str, price | to_str }
        from_data.each do | to_str, price |
            my_current_to = Date.parse(to_str)
            print "\tto #{my_current_to.strftime(date_format)}: ".light_blue
            puts ColoredNumber.new(price, ranges).getLowestPriceWithColor
            # puts price.to_s
            #     puts ColoredNumber.new(number, ranges).getLowestPriceWithColor
        end
    }
end



# trip.setRanges(options['price_ranges'])

# prices.each do | number |
#     puts ColoredNumber.new(number, ranges).getLowestPriceWithColor
# end

# puts "\t- To ".blue + "#{current_to.strftime(date_format)}:".light_blue + " #{trip.getLowestPriceWithColor}"
# File.open(output, 'a') {|file|
#     file.write "#{trip.start_date.day};#{trip.start_date.month};#{trip.start_date.year};#{trip.end_date.day};#{trip.end_date.month};#{trip.end_date.year};" + price + "\n"
# }

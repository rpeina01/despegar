require 'colorize'

class Trip
    attr_accessor :base_url, :start_date, :end_date, :debug
    attr_reader :response

    def initialize(origin_city = nil, destination_city = nil, start_date = nil, end_date = nil)
        @origin_city = origin_city
        @destination_city = destination_city
        @start_date = start_date
        @end_date = end_date
    end

    def details
        "City code: #{@origin_city} | from: #{@start_date} to #{@end_date}"
    end

    def getURL
        puts "You must provide a base_url" and exit if @base_url.nil?
        "#{@base_url}#{@origin_city}/#{@destination_city}/#{@start_date.year}-#{@start_date.month}-#{@start_date.day}/#{@end_date.year}-#{@end_date.month}-#{@end_date.day}/1/0/0/TOTALFARE/ASCENDING/NA/NA/NA/NA/NA"
    end

    def getLowestPrice
        @response["result"]["data"]["items"].first["emissionPrice"]["total"]["fare"]["raw"]
    end

    def getData
        if @debug
            response = File.read('lib/answer_example.json')
            sleep(0.5)
        else
            uri = URI(self.getURL)
            response = Net::HTTP.get(uri)
        end
        @response = JSON.parse(response)
    end

    def setRanges(price_ranges)
        @price_ranges = price_ranges
    end

    def getLowestPriceWithColor
        lowest_price = getLowestPrice

        return lowest_price.formatWithPoints if @price_ranges.nil?

        price_output = lowest_price.formatWithPoints
        if lowest_price >= @price_ranges['excessive']
            price_output = price_output.red
        elsif lowest_price >= @price_ranges['expensive']
            price_output = price_output.light_red
        elsif lowest_price >= @price_ranges['moderate']
            price_output = price_output.yellow
        elsif lowest_price >= @price_ranges['moderate_to_cheap']
            price_output = price_output.light_yellow
        elsif lowest_price >= @price_ranges['cheap']
            price_output = price_output.green
        else
            price_output = price_output.light_green
        end
        price_output
    end

    def to_s
        date_format = '%d %b'
        "Trip to #{@origin_city} from #{@start_date.strftime(date_format)} to #{@end_date.strftime(date_format)}: #{getLowestPriceWithColor}"
    end
end

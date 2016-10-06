require 'colorize'

class Trip
    attr_accessor :base_url, :start_date, :end_date
    attr_reader :response

    def initialize(city_code = nil, start_date = nil, end_date = nil)
        @city_code = city_code
        @start_date = start_date
        @end_date = end_date
        @base_url = 'http://www.despegar.cl/shop/flights/data/search/roundtrip/scl/'
    end

    def details
        "City code: #{@city_code} | from: #{@start_date} to #{@end_date}"
    end

    def getURL
        "#{@base_url}#{@city_code}/#{@start_date.year}-#{@start_date.month}-#{@start_date.day}/#{@end_date.year}-#{@end_date.month}-#{@end_date.day}/1/0/0/TOTALFARE/ASCENDING/NA/NA/NA/NA/NA"
    end

    def getLowestPrice
        @response["result"]["data"]["items"].first["emissionPrice"]["total"]["fare"]["raw"]
    end

    def getData
        uri = URI(self.getURL)
        response = Net::HTTP.get(uri)
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
        "#{@start_date.day}/#{@start_date.month} to #{@end_date.day}/#{@end_date.month}: #{getLowestPriceWithColor}"
    end
end

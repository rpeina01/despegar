class Trip
    attr_accessor :base_url
    attr_reader :response

    def initialize(city_code = nil, start_date = nil, end_date = nil)
        @city_code = city_code
        @start_date = start_date
        @end_date = end_date
        @base_url = 'http://www.despegar.cl/shop/flights/data/search/roundtrip/scl/'
    end

    def to_s
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
end

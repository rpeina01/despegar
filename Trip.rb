class Trip
    attr_accessor :base_url

    def initialize(city_code = nil, start_date = nil, end_date = nil)
        @city_code = city_code
        @start_date = start_date
        @end_date = end_date
        @base_url = 'http://www.despegar.cl/shop/flights/data/search/roundtrip/scl/'
    end

    def to_s
        "City code: #{@city_code} | from: #{@start_date} to #{@end_date}"
    end
end

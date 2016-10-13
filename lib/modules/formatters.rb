module Formatters
    def self.formatEmail(date_format, ranges)
        print "+"
        print "-" * 200
        puts "+"
        lambda { | from_str, from_data |
            my_from = Date.parse(from_str)
            print '|' + " From: ".blue + "#{my_from.strftime(date_format)}".light_blue
            from_data = from_data.sort_by { | to_str, price | to_str }
            from_data.each do | to_str, price |
                my_current_to = Date.parse(to_str)
                print "|   #{my_current_to.strftime(date_format)}: ".light_blue
                print ColoredNumber.new(price, ranges).getLowestPriceWithColor
            end
            puts
            print "-" * 200
            puts " |"
        }
    end
end

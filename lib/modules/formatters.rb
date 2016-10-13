module Formatters
    def self.formatEmail(date_format, ranges)
        lambda { | from_str, from_data |
            my_from = Date.parse(from_str)
            puts "From: ".blue + "#{my_from.strftime(date_format)}".light_blue
            from_data = from_data.sort_by { | to_str, price | to_str }
            from_data.each do | to_str, price |
                my_current_to = Date.parse(to_str)
                print "\tto #{my_current_to.strftime(date_format)}: ".light_blue
                puts ColoredNumber.new(price, ranges).getLowestPriceWithColor
            end
        }
    end
end

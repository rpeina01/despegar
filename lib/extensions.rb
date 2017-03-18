class Integer
    def formatWithPoints
        self.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
    end
end

class Date
    def tomorrow
        self + 1
    end

    def yesterday
        self - 1
    end

    def addDays(days)
        self + days
    end
    def substractDays(days)
        self - days
    end
end

# From http://stackoverflow.com/questions/1341271/how-do-i-create-an-average-from-a-ruby-array
class Array
    def sum
        inject(0.0) { |result, el| result + el }
    end

    def mean
        sum / size
    end
end

def percentile(values, percentile)
    values_sorted = values.sort
    k = (percentile*(values_sorted.length-1)+1).floor - 1
    f = (percentile*(values_sorted.length-1)+1).modulo(1)

    return values_sorted[k] + (f * (values_sorted[k+1] - values_sorted[k]))
end

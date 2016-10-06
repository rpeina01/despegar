class Fixnum
    def formatWithPoints
        self.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
    end
end

class Time
    def tomorrow
        self + 60 * 60 * 24
    end

    def yesterday
        self - 60 * 60 * 24
    end

    def addDays(days)
        self + days * 60 * 60 * 24
    end
    def substractDays(days)
        self - days * 60 * 60 * 24
    end
end

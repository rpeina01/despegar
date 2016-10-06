require 'logger'
module CustomLogger
    def self.getLog(output, level)
        logger = Logger.new(output)
        logger.level = level

        logger.formatter = proc do | severity, datetime, progname, message |
            case severity
            when 'ERROR'
                "Error: ".red + "#{message.light_red}\n"
            when 'INFO'
                "Info:  ".blue + "#{message.light_blue}\n"
            else
                "Severity #{severity} not coded"
            end
        end
        return logger
    end
end

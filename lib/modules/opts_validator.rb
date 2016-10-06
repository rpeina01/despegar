class OptsValidator
    def initialize(options, logger)
        @options = options
        @logger  = logger
    end

    def validate_presence_of(symbol, description, flag)
        @logger.error("You must provide a #{description} (-#{flag} flag)") and exit if @options[symbol].nil?
    end
end

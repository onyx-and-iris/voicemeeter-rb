require "logger"

module Voicemeeter
  module Logging
    def logger
      @logger = Logger.new($stdout, level: ENV.fetch("LOG_LEVEL", "WARN"))
      @logger.progname = self.class.name
      @logger
    end
  end
end

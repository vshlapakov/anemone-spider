require "base64"
require "json"
require "logger"


module Logging
  # Magic logger class recording the classname with log messages
  def logger
    @logger ||= Logging.logger_for(self.class.name)
  end

  # Use a hash class-ivar to cache a unique Logger per class:
  @loggers = {}

  class << self
    def logger_for(classname)
      @loggers[classname] ||= configure_logger_for(classname)
    end

    def configure_logger_for(classname)
      logger = Logger.new(STDOUT)
      logger.progname = classname
      logger
    end
  end
end

module CrawlTools

  def parse_environment
    {
      :JOB_DATA => decode_json_from_env('SHUB_JOB_DATA'),
      :JOB_SETTINGS => decode_json_from_env('SHUB_SETTINGS'),
      :SHUB_STORAGE => ENV.fetch('SHUB_STORAGE', 'https://storage.scrapinghub.com'),
      :SHUB_APIURL => ENV.fetch('SHUB_APIURL', 'https://dash.scrapinghub.com')
    }
  end

  def decode_json_from_env(env)
    uri = ENV.fetch(env)
    JSON.parse(uri)
  end

  module_function :parse_environment
  module_function :decode_json_from_env

end

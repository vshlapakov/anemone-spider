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
      :JOB_DATA => decode_uri(env: 'JOB_DATA'),
      :JOB_SETTINGS => decode_uri(env: 'JOB_SETTINGS'),
      :SHUB_STORAGE => ENV.fetch('SHUB_STORAGE', 'https://storage.scrapinghub.com'),
      :SHUB_APIURL => ENV.fetch('SHUB_APIURL', 'https://dash.scrapinghub.com')
    }
  end

  def decode_uri(uri: nil, env: nil)
    if !env.nil?
      uri = ENV.fetch(env)
    elsif uri.nil?
      raise ValueError, "An uri or envvar is required"
    end

    mime_type = 'application/json'

    # data:[<MIME-type>][;charset=<encoding>][;base64],<data>
    if uri.start_with?("data:")
      prefix, _, data = uri.rpartition(',')
      mods = {}

      prefix[5..-1].split(';').each_with_index do |value,idx|
        if idx == 0
          mime_type = value or mime_type
        elsif value.include? '='
          k, _, v = value.partition('=')
          mods[k] = v
        else
          mods[value] = nil
        end
      end

      if mods.include? 'base64'; data = Base64.decode64(data) end
      if mime_type.eql? 'application/json'
        return JSON.parse(data) else return data end

    end

    if uri.start_with?("{"); return JSON.parse(uri) end

    if uri.start_with?('/'); uri = 'file://' + uri end
    if uri.start_with?('file://'); JSON.parse(File.read(uri[7..-1])) end

  end

  module_function :parse_environment
  module_function :decode_uri

end

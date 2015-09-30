#!/usr/bin/env ruby
require 'rubygems'
require 'logger'
require 'bundler/setup'
require_relative 'spiders'
require_relative 'utils'

include Logging

class AnemoneCrawler

  @@spiders = { 'argenteam' => ArgenteamSpider }

  def self.crawl(settings)
    # use spider name in settings to create a new instance
    spidername = settings[:JOB_DATA]["spider"]
    if not spidername; raise ValueError, "No spider name" end

    logger.info ["Starting crawl process for '", spidername, "' spider"]
    spider = @@spiders[spidername].new(settings)
    spider.crawl
  end

end

begin
  logger.info('Starting crawler.')
  settings = CrawlTools.parse_environment
  logger.info ['Extracted settings:', settings].inspect
  AnemoneCrawler.crawl(settings)
  logger.info('Closing crawler.')
end

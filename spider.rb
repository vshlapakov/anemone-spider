#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'json'
require 'net/http'
require 'uri'
require 'anemone'


jobdata = JSON.parse(File.read(ENV['JOB_DATA']))
hubstorage = ENV.fetch('SHUB_STORAGE', 'https://storage.scrapinghub.com')
JOBKEY = jobdata['key']
JOBAUTH = jobdata['auth']
ITEMSURL = URI.parse("#{hubstorage}/items/#{JOBKEY}")
puts ITEMSURL
#ITEMSURL = URI.parse('http://requestb.in/17qg9r11')


def senditem(item)
  http = Net::HTTP.new(ITEMSURL.host, ITEMSURL.port)
  req = Net::HTTP::Post.new(ITEMSURL.request_uri)
  req.basic_auth(JOBKEY, JOBAUTH)
  req.body = JSON.generate(item)
  req.content_type = 'application/json'
  res = http.request(req)
end


count = 0
Anemone.crawl("http://www.suggestmemovie.com/") do |anemone|
  anemone.on_every_page do |page|
    count += 1
    puts page.url
    senditem({:url => page.url})
    exit if count > 10
  end
end

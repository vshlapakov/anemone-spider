#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'json'
require 'net/http'
require 'uri'
require 'anemone'

JOBDATAFILE = ENV.fetch('JOB_DATA', nil)
if JOBDATAFILE then
  JOBDATA = JSON.parse(File.read(ENV['JOB_DATA']))
else
  JOBDATA = nil
end
HUBSTORAGE = ENV.fetch('SHUB_STORAGE', 'https://storage.scrapinghub.com')


def upload(prefix, item, params)
  puts "--> HS #{prefix} #{item} #{params}"
  return if not JOBDATA
  uri = URI("#{HUBSTORAGE}/#{prefix}/#{JOBDATA['key']}")
  uri.query = URI.encode_www_form(params)
  http = Net::HTTP.new(uri.host, uri.port)
  req = Net::HTTP::Post.new(uri.request_uri)
  req.basic_auth(JOBDATA['key'], JOBDATA['auth'])
  req.body = JSON.generate(item)
  req.content_type = 'application/json'
  res = http.request(req)
  puts "<-- HS #{res.code} #{res.url} #{res.body}"
end


offset = 0
Anemone.crawl("http://www.argenteam.net/") do |anemone|
  anemone.on_pages_like(/movie\/\d+\/.*/) do |page|
    puts "#{page.code} #{page.url}"
    title = page.doc.at_xpath("//div[@class='pmovie']/h1").text rescue nil
    description = page.doc.at_xpath("//div[@class='pmovie']/div[@class='details']").text rescue nil
    image = page.doc.at_xpath("//div[@class='pmovie']/img[@class='poster']").attribute("src") rescue nil

    upload('logs', {:message => page.url.to_s, :level => 20}, {:start => offset})
    upload('items',
           {:url => page.url.to_s,
            :title => title,
            :description => description,
            :images => [image]},
           {:start => offset})
    offset += 1
    exit if offset > 10
  end
end

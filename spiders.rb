require 'anemone'
require 'net/http'
require "time"
require 'uri'

class ArgenteamSpider

  @@xpathes = {
    :title => "//div[@class='pmovie']/h1",
    :desc => "//div[@class='pmovie']/div[@class='details']",
    :image => "//div[@class='pmovie']/img[@class='poster']"
  }

  def initialize(settings)
    @settings = settings
  end

  def upload(prefix, item, params)
    logger.info "--> HS #{prefix} #{item} #{params}"
    job_data     = @settings[:JOB_DATA]
    shub_storage = @settings[:SHUB_STORAGE]
    return if not job_data

    job_key, job_auth = job_data["key"], job_data["auth"]
    uri = URI.join("#{shub_storage}", "#{prefix}/#{job_key}/")
    uri.query = URI.encode_www_form(params)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    req = Net::HTTP::Post.new(uri.request_uri)
    req.basic_auth(job_key, job_auth)
    req.body = JSON.generate(item)
    req.content_type = 'application/json'
    logger.debug "HS request: #{uri} #{uri.query} #{req.body}"

    response = http.request(req)
    if response.is_a?(Net::HTTPSuccess)
        logger.info "<-- HS #{response.code} #{response.uri} #{response.body}"
    else
        logger.warning "HS bad response #{response}"
    end
  end

  def crawl
    offset = 0
    Anemone.crawl("http://www.argenteam.net/") do |anemone|

      anemone.on_pages_like(/movie\/\d+\/.*/) do |page|

        logger.info "#{page.code} #{page.url}"

        title = page.doc.at_xpath(@@xpathes[:title]).text rescue nil
        description = page.doc.at_xpath(@@xpathes[:desc]).text rescue nil
        image = page.doc.at_xpath(@@xpathes[:image]).attribute("src") rescue nil

        upload('logs',
          {:message => page.url.to_s,
           :level => 20,
           :time => Time.now.to_i},
           {:start => offset})
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
  end

end

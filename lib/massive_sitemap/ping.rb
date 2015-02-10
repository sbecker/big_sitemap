# Copyright (c) 2012, SoundCloud Ltd., Tobias Bielohlawek

require 'cgi'
require 'open-uri'

# Ping Search Engines to pull the latest update
module MassiveSitemap
  extend self

  ENGINES_URLS = {
    :google => 'http://www.google.com/webmasters/tools/ping?sitemap=%s',
    :bing   => 'http://www.bing.com/webmaster/ping.aspx?siteMap=%s',
    :ask    => 'http://submissions.ask.com/ping?sitemap=%s',
    :yandex => 'http://webmaster.yandex.ru/wmconsole/sitemap_list.xml?host=%s',
  }

  DEFAULT_ENGINES = [:google, :bing, :yandex] #ask seems to be down, so disable for now by default

  def ping(url, engines = DEFAULT_ENGINES)
    url =  verify_and_escape(url)

    Array(engines).each do |engine|
      if engine_url = ENGINES_URLS[engine]
        begin
          open(engine_url % url)
        rescue => e
          log_error(engine, e)
        end
      end
    end
  end

  private
  def verify_and_escape(url)
    schema, host, path = url.scan(/^(https?:\/\/)?(.+?)(\/.+)$/).flatten
    raise URI::InvalidURIError, url if path.to_s.empty?
    CGI::escape("#{schema || 'http://'}#{host}#{path}")
  end

  def log_error(engine, error)
    $stderr.puts "Error pinging #{engine} #{error.message}"
  end
end

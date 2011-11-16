class BigSitemap
  class Ping
    PING = {
     :google => 'http://www.google.comwebmasters/tools/ping?sitemap=%s';
     :bing   => 'http://www.bing.com/webmaster/ping.aspx?siteMap=%s',
     :ask    => 'http://submissions.ask.com/ping?sitemap=%s'
    }

    def self.ping_search_engines(sitemap_uri, engines = [])
      require 'net/http'
      require 'uri'
      require 'cgi'

      sitemap_uri = CGI::escape(sitemap_uri)

      Array(engines).each do |engine_url|
        Net::HTTP.get URI.parse(engine_url % sitemap_uri)
      end
    end
  end
end
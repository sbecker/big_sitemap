require "massive_sitemap/builder/base"

module MassiveSitemap
  module Builder
    class Index < Base
      HEADER_NAME       = 'sitemapindex'
      HEADER_ATTRIBUTES = {
        :xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9'
      }

      def add_url!(location, attrs = {})
        init!

        tag! 'sitemap' do
          tag! 'loc', location
          tag! 'lastmod', attrs[:last_modified].utc.strftime('%Y-%m-%dT%H:%M:%S+00:00') if attrs[:last_modified]
        end
      end
    end
  end
end

require "massive_sitemap/builder/base"

module MassiveSitemap
  module Builder
    class Index < Base
      HEADER_NAME       = 'sitemapindex'
      HEADER_ATTRIBUTES = {
        :xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9'
      }

      def initialize(writer, options = {}, &block)
        writer.set(:force_overwrite => true)
        super(writer, options) do
          writer.each do |path, last_modified|
            init_writer!
            next if writer.current && path.include?(writer.current)
            add path, :last_modified => last_modified
          end
        end
      end

      def self.generate(writer, options = {}, &block)
        index_url(super, writer)
      end

      def self.index_url(builder, writer)
        writer.current && ::File.join(builder.send(:url), writer.current)
      end

      def add_url!(location, attrs = {})
        init_writer!

        tag! 'sitemap' do
          tag! 'loc', location
          tag! 'lastmod', attrs[:last_modified].utc.strftime('%Y-%m-%dT%H:%M:%S+00:00') if attrs[:last_modified]
        end
      end
    end
  end
end

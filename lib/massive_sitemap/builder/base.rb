module MassiveSitemap
  module Builder

    class Base
      OPTS = {
        :base_url  => nil,
        :indent_by => 2
      }

      HEADER_NAME = 'urlset'
      HEADER_ATTRIBUTES = {
        'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9',
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xsi:schemaLocation' => "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
      }

      attr_reader :options

      def initialize(writer, options = {}, &block)
        @writer  = writer
        @options = OPTS.merge(options)
        @builder = self
        init!(&block)
      end

      def add(path, attrs = {})
        add_url! File.join(options[:base_url], path), attrs
      end

      def init!(&block) #_init_document
        @writer.init!
        @opened_tags = []
        @writer.print '<?xml version="1.0" encoding="UTF-8"?>'
        tag! self.class::HEADER_NAME, self.class::HEADER_ATTRIBUTES, &block
      end

      def add_url!(location, attrs = {})
        tag! 'url' do
          tag! 'loc', location
          tag! 'lastmod', attrs[:last_modified].utc.strftime('%Y-%m-%dT%H:%M:%S+00:00') if attrs[:last_modified]
          tag! 'changefreq', attrs[:change_frequency] if attrs[:change_frequency]
          tag! 'priority', attrs[:priority].to_s if attrs[:priority]
        end
      end

      def tag!(name, content = nil, attrs = {}, &block) # _tag
        attrs = content if content.is_a? Hash
        open!(name, attrs)
        if content.is_a? String
          @writer.print content.gsub('&', '&amp;')
          close!(false)
        else
          if block
            instance_eval(&block)
            close!
          end
        end
      end

      def open!(name, attrs = {}) #_open_tag
        attrs = attrs.map { |attr, value| %Q( #{attr}="#{value}") }.join('')
        @writer.print "\n" + ' ' * options[:indent_by] * @opened_tags.size
        @opened_tags << name
        @writer.print "<#{name}#{attrs}>"
      end

      def close!(indent = true) #_close_tag / #_close_document
        name = @opened_tags.pop
        @writer.print "\n" + ' ' * options[:indent_by] * @opened_tags.size if indent
        @writer.print "</#{name}>"
        @writer.close! if @opened_tags.size == 0
      end
    end
  end
end
module MassiveSitemap
  module Builder

    class Base
      OPTS = {
        :url       => nil,
        :indent_by => 2
      }

      HEADER_NAME       = 'urlset'
      HEADER_ATTRIBUTES = {
        'xmlns'              => 'http://www.sitemaps.org/schemas/sitemap/0.9',
        'xmlns:xsi'          => "http://www.w3.org/2001/XMLSchema-instance",
        'xsi:schemaLocation' => "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
      }

      def initialize(writer, options = {}, &block)
        @writer      = writer
        @options     = self.class::OPTS.merge(options)
        @opened_tags = []

        if block
          instance_eval(&block)
          close!
        end
      end

      def self.generate(writer, options = {}, &block)
        self.new(writer, options, &block)
      end

      def add(path, attrs = {})
        add_url! ::File.join(url, path), attrs
      rescue MassiveSitemap::Writer::File::FileExistsException => e
        # don't fail here
      end

      # implicitly called by add_url!, call explicitly to check if writer can be used
      def init_writer!(writer_options = {})
        unless @writer.inited?
          @writer.init!(writer_options)
          header!
        end
      end

      def close!(indent = true)
        if name = @opened_tags.pop
          @writer.print "\n" + ' ' * @options[:indent_by] * @opened_tags.size if indent
          @writer.print "</#{name}>"
          if @opened_tags.size == 0
            @writer.close!
            true
          end
        end
      end

      private
      def header!(&block)
        @writer.print '<?xml version="1.0" encoding="UTF-8"?>'
        tag! self.class::HEADER_NAME, self.class::HEADER_ATTRIBUTES, &block
      end

      def add_url!(location, attrs = {})
        init_writer!

        tag! 'url' do
          tag! 'loc', location
          tag! 'lastmod', attrs[:last_modified].utc.strftime('%Y-%m-%dT%H:%M:%S+00:00') if attrs[:last_modified]
          tag! 'changefreq', attrs[:change_frequency] if attrs[:change_frequency]
          tag! 'priority', attrs[:priority].to_s if attrs[:priority]
        end
      end

      def tag!(name, content = nil, attrs = {}, &block)
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

      def open!(name, attrs = {})
        attrs = attrs.map { |attr, value| %Q( #{attr}="#{value}") }.join('')
        @writer.print "\n" + ' ' * @options[:indent_by] * @opened_tags.size
        @opened_tags << name
        @writer.print "<#{name}#{attrs}>"
      end

      private
      def url
        schema, host = @options[:url].scan(/^(https?:\/\/)?(.+?)\/?$/).flatten
        "#{schema || 'http://'}#{host}/"
      rescue
         ""
      end
    end
  end
end


# writer only has print and puts as interface

class BigSitemap
  class Builder
    HEADER_NAME = 'urlset'
    HEADER_ATTRIBUTES = {
      'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9',
      'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
      'xsi:schemaLocation' => "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
    }
    OPTS = {
      :indent_by => 2
    }

    def initialize(writer, opts = {}, &block)
      @opt = OPTS.merge(opts)
      @writer = writer
      init!(&block)
    end

    def init!(&block) #_init_document
      @opened_tags = []
      @writer.print '<?xml version="1.0" encoding="UTF-8"?>'
      tag! self.class::HEADER_NAME, self.class::HEADER_ATTRIBUTES, &block
    end

    def add_url!(location, options = {})
      tag! 'url' do
        tag! 'loc', location
        tag! 'lastmod', options[:last_modified].utc.strftime('%Y-%m-%dT%H:%M:%S+00:00') if options[:last_modified]
        tag! 'changefreq', options[:change_frequency] if options[:change_frequency]
        tag! 'priority', options[:priority].to_s if options[:priority]
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
      @writer.print "\n" + ' ' * @opt[:indent_by] * @opened_tags.size
      @opened_tags << name
      @writer.print "<#{name}#{attrs}>"
    end

    def close!(indent = true) #_close_tag / #_close_document
      name = @opened_tags.pop
      @writer.print "\n" + ' ' * @opt[:indent_by] * @opened_tags.size if indent
      @writer.print "</#{name}>"
      #TODO close writer if none opened_tags left??
    end
  end

  class IndexBuilder < Builder
    HEADER_NAME = 'sitemapindex'
    HEADER_ATTRIBUTES = {
      'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9'
    }

    def add_url!(location, options={})
      tag! 'sitemap' do
        tag! 'loc', location
        tag! 'lastmod', options[:last_modified].utc.strftime('%Y-%m-%dT%H:%M:%S+00:00') if options[:last_modified]
      end
    end
  end

  class RotatingBuilder < Builder
    MAX_URLS = 50_000

    def init!(&block)
      @urls = 0
      super
    end

    def add_url!(location, options={})
      if @urls >= MAX_URLS
        close!
        @writer.rotate
        init!
      end
      super
      @urls += 1
    end
  end
end

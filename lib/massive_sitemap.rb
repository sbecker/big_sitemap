require 'massive_sitemap/writer/file'
require 'massive_sitemap/writer/gzip_file'
require 'massive_sitemap/builder/rotating'
require 'massive_sitemap/builder/index'
require 'massive_sitemap/lock'
require 'massive_sitemap/ping'

# Page at -> <url>
# http://example.de/dir/

# Index at -> <index_url>
# http://sitemap.example.de/index-dir/

# Save at -> <root>
# /root/dir/ ->  <document_root>/<document_path>

module MassiveSitemap
  DEFAULTS = {
    # global
    :index_url       => nil,
    :gzip            => false,
    :writer          => MassiveSitemap::Writer::File,

    # writer
    :root            => '.',
    :force_overwrite => false,
    :filename        => "sitemap.xml",
    :index_filename  => "sitemap_index.xml",

    # builder
    :url             => nil,
    :indent_by       => 2,
  }

  def generate(options = {}, &block)
    lock! do
      @options = DEFAULTS.merge options

      unless @options[:url]
        raise ArgumentError, 'you must specify ":url" string'
      end
      @options[:index_url] ||= @options[:url]

      if @options[:max_urls] && !Builder::Rotating::NUM_URLS.member?(@options[:max_urls])
        raise ArgumentError, %Q(":max_urls" must be greater than #{NUM_URLS.min} and smaller than #{NUM_URLS.max})
      end

      @options[:writer] = Writer::GzipFile if @options[:gzip]

      @writer = @options[:writer].new @options
      Builder::Rotating.generate(@writer, @options, &block)

      @writer.init!(:filename => @options[:index_filename], :force_overwrite => true)
      Builder::Index.generate(@writer, @options.merge(:url => @options[:index_url]))
    end
  end
  module_function :generate

end

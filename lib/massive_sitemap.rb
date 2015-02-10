# Copyright (c) 2012, SoundCloud Ltd., Tobias Bielohlawek

require 'massive_sitemap/writer/file'
require 'massive_sitemap/writer/gzip_file'
require 'massive_sitemap/builder/rotating'
require 'massive_sitemap/builder/index'
require 'massive_sitemap/lock'
require 'massive_sitemap/ping'

# MassiveSitemap
# Example Standard setup of  a writer, rotating and index builder.
# Common parameters:
#  required:
#   :url  - Url of your website e.g http://example.de/dir/
#
#  optional:
#   :index_url - Url of your index website e.g http://example.de/sitemap
#   :root  - directory where files get written to e.g. /var/sitemap
#   :gzip - wether to gzip files or not
#   :writer - custom wirter

module MassiveSitemap
  DEFAULTS = {
    # global
    :index_url       => nil,
    :index_filename  => "sitemap_index.xml",
    :gzip            => false,

    # writer
    :root            => '.',
    :force_overwrite => false,
    :filename        => "sitemap.xml",

    # builder
    :url             => nil,
    :indent_by       => 2,
  }

  def generate(options = {}, &block)
    lock! do
      @options = DEFAULTS.merge options

      unless @options[:url]
        raise ArgumentError, %Q(":url" not given)
      end
      @options[:index_url] ||= @options[:url]

      if @options[:max_urls] && !Builder::Rotating::NUM_URLS.member?(@options[:max_urls])
        raise ArgumentError, %Q(":max_urls" must be greater than #{Builder::Rotating::NUM_URLS.min} and smaller than #{Builder::Rotating::NUM_URLS.max})
      end

      @writer   = @options.delete(:writer)
      @writer ||= (@options.delete(:gzip) ? Writer::GzipFile : Writer::File).new

      Builder::Rotating.generate(@writer.set(@options), @options, &block)

      @writer.set(:filename => @options[:index_filename])
      Builder::Index.generate(@writer, @options.merge(:url => @options[:index_url]))
    end
  end
  module_function :generate

end

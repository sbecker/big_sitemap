require 'uri'
require 'fileutils'

require 'big_sitemap/builder'
require 'big_sitemap/writer'

# Page at -> <base_url>
# http://example.de/dir/

# Index at
# http://sitemap.example.de/index-dir/

# Save at -> <document_full>
# /root/dir/ ->  <document_root>/<document_path>

class BigSitemap
  DEFAULTS = {
    # :max_per_sitemap => RotatingBuilder::MAX_URLS,
    # :indent          => Builder::OPTS[:indent_by],

    :document_root   => '.',
    :document_path   => '/',
    #:index_path     => '/',

    :gzip            => true,

    # Opinionated
    :ping => [:google]
  }

  attr_reader :options

  class << self
    def generate(options={}, &block)
      self.new(options).tap do |sitemap|
        FileWriter.new(sitemap.options[:document_full] + "sitemap.xml").tap do |writer|
          @builder = RotatingBuilder.new(writer)# do |builder| #TODO opts: indent, max_per_sitemap
          instance_eval(&block) if block
          @builder.close!
          writer.close
        end

        #sitemap.generate_index
        # BigSitemap::ping_search_engines(url, options[:ping])
      end
    end

    private
    def add(path, options={})
      #url = File.join @options[:base_url], path
      @builder.add_url! path, options
    end
  end

  def initialize(options={})
    @options = DEFAULTS.merge options

    #gets prefixed to url if 'http' is missing
    unless @options[:base_url]
      raise ArgumentError, 'you must specify ":base_url" string'
    end

    @options[:url_path] ||= @options[:document_path]

    @options[:document_full] ||= File.join(@options[:document_root], @options[:document_path])
    unless @options[:document_full]
      raise ArgumentError, 'Document root must be specified with the ":document_root" option, the full path with ":document_full"'
    end

    Dir.mkdir(@options[:document_full]) unless File.exists?(@options[:document_full])
  end

  # Create a sitemap index document
  def generate_index(files = Dir[sitemap_files])
    File.open(@options[:document_full] + "sitemap_index.xml") do |writer|
      IndexBuilder.new('sitemap_index') do |builder|
        files.each do |path|
          next if path =~ /index/
          builder.add_url! url_for_sitemap(path), :last_modified => File.stat(path).mtime
        end
      end
    end
  end


  def sitemap_files
    File.join(@options[:document_full], "*.{xml,xml.gz}")
  end

  def url_for_sitemap(path)
    File.join @options[:base_url], @options[:url_path], path
  end

  def clean!
    Dir[sitemap_files].each do |file|
      FileUtils.rm file
    end
  end


end

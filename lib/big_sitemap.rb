require 'uri'
require 'fileutils'

require 'big_sitemap/builder'

class BigSitemap
  DEFAULTS = {
    :max_per_sitemap => Builder::MAX_URLS,
    :document_path   => '/',
    :gzip            => true,
    # :indent        => 2

    # Opinionated
    :ping => [:google]
  }

  class << self
    def generate(options={}, &block)
      self.new(options).tap do |sitemap|
        sitemap.with_lock do
          sitemap.clean

          sitemap.add_set do |builder|
            @builder = builder
            instance_eval(&block)
          end

          url = sitemap.generate_sitemap_index
          BigSitemap::ping_search_engines(url, options[:ping])
        end
      end
    end

    private
    def add(path, options={})
      #url = File.join @options[:base_url], File.basename(path)
      @builder.add_url! path, options
    end

    def add_set(options={})
      options[:filename]       ||= file_name(options[:name])

      klass = options.delete(:type) == 'index' ? IndexBuilder : Builder.
      klass.new(options)

      begin
        yield builder
      ensure
        builder.close!
      end
    end
  end

  def initialize(options={})
    @options = DEFAULTS.merge options

    unless (2..Builder::MAX_URLS).member?(@options[:max_per_sitemap])
      raise ArgumentError, "\":max_per_sitemap\" must be greater than 1 and smaller than #{Builder::MAX_URLS}"
    end

    #gets prefixed to url if 'http' is missing
    unless @options[:base_url]
      raise ArgumentError, 'you must specify either ":base_url" string'
    end

    @options[:url_path] ||= @options[:document_path]

    unless @options[:document_root]
      raise ArgumentError, 'Document root must be specified with the ":document_root" option"'
    end

    @options[:document_full] ||= File.join(@options[:document_root], @options[:document_path])
    unless @options[:document_full]
      raise ArgumentError, 'Document root must be specified with the ":document_root" option, the full path with ":document_full"'
    end

    Dir.mkdir(@options[:document_full]) unless File.exists?(@options[:document_full])

    @sitemap_files = []
  end

  def with_lock
    lock!
    begin
      yield
    ensure
      unlock!
    end
  rescue Errno::EACCES => e
    STDERR.puts 'Lockfile exists' if $VERBOSE
  end

  def sitemap_files
    File.join(@options[:document_full], "sitemap*.{xml,xml.gz}")
  end

  def url_for_sitemap(path)
    File.join @options[:base_url], @options[:url_path], File.basename(path)
  end

  def clean
    Dir[sitemap_files].each do |file|
      FileUtils.rm file
    end

    self
  end

  # Create a sitemap index document
  def generate_sitemap_index(files=Dir[sitemap_files])

    add_set(:name => 'index', :type => 'index') do |sitemap|
      for path in files
        next if path =~ /index/
        sitemap.add_url! url_for_sitemap(path), :last_modified => File.stat(path).mtime
      end
    end

    self
  end

  private
  def lock!(lock_file = 'generator.lock')
    lock_file = File.join(@options[:document_full], lock_file)
    File.open(lock_file, 'w', File::EXCL)
  end

  def unlock!(lock_file = 'generator.lock')
    lock_file = File.join(@options[:document_full], lock_file)
    FileUtils.rm lock_file
  end

  def file_name(name=nil)
    name   = table_name(name) unless (name.nil? || name.is_a?(String))
    prefix = 'sitemap'
    prefix << '_' unless name.nil?
    File.join(@options[:document_full], "#{prefix}#{name}")
  end
end

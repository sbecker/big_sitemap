# require 'uri'
# require 'fileutils'

require "massive_sitemap/version"

require 'massive_sitemap/writer/file'
require 'massive_sitemap/writer/gzip_file'
require 'massive_sitemap/builder/rotating'
require 'massive_sitemap/builder/index'

# Page at -> <base_url>
# http://example.de/dir/

# Index at
# http://sitemap.example.de/index-dir/

# Save at -> <document_full>
# /root/dir/ ->  <document_root>/<document_path>

module MassiveSitemap
  DEFAULTS = {
    # builder
    :base_url               => nil,
    :indent_by              => 2,

    # writer
    :document_full          => '.',
    :force_overwrite        => false,
    :sitemap_filename       => "sitemap.xml",
    :index_filename         => "sitemap_index.xml",
    # writer gzip
    :gzip                   => false,
  }

  def generate(options = {}, &block)
    @options = DEFAULTS.merge options

    unless options[:base_url]
      raise ArgumentError, 'you must specify ":base_url" string'
    end

    Dir.mkdir(options[:document_full]) unless ::File.exists?(@options[:document_full])

    @writer_class = @options[:gzip] ? Writer::GzipFile : Writer::File

    generate_sitemap(&block)
  end
  module_function :generate

  def generate_sitemap(&block)
    @writer = @writer_class.new @options[:sitemap_filename], @options
    @builder = Builder::Rotating.new(@writer, @options)
    instance_eval(&block) if block
    @builder.close!
    self
  end
  module_function :generate_sitemap

  # Create a sitemap index document
  def generate_index(files = nil)
    ext     = @options[:gzip] ? "xml.gz" : "xml"
    files ||= Dir[File.join(@options[:document_full], "*.#{ext}")]

    @writer = @writer_class.new @options[:index_filename], @options.merge(:force_overwrite => true)
    Builder::Index.new(@writer, @options.merge(:base_url => "http://test.de")) do
      files.each do |path|
        next if path.include?(@options[:index_filename])
        add ::File.basename(path), :last_modified => File.stat(path).mtime
      end
    end
    self
  end
  module_function :generate_index

  def add(path, attrs = {})
    @builder.add(path, attrs)
  end
  module_function :add
end

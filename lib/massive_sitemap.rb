# require 'uri'
# require 'fileutils'

require "massive_sitemap/version"

require 'massive_sitemap/writer/file'
require 'massive_sitemap/builder/rotating'

# Page at -> <base_url>
# http://example.de/dir/

# Index at
# http://sitemap.example.de/index-dir/

# Save at -> <document_full>
# /root/dir/ ->  <document_root>/<document_path>

# require 'massive_sitemap/builder/index'

module MassiveSitemap
  DEFAULTS = {
    # writer
    :document_full   => '.',

    # builder
    :base_url        => nil,
    :indent_by       => 2,
  }

  def generate(options = {}, &block)
    options = DEFAULTS.merge options

    unless options[:base_url]
      raise ArgumentError, 'you must specify ":base_url" string'
    end
    options[:base_url] = beauty_url(options[:base_url])

    Dir.mkdir(options[:document_full]) unless ::File.exists?(options[:document_full])

    writer_class = options.delete(:gzip) ? Writer::GzipFile : Writer::File

    @writer = writer_class.new "sitemap.xml", options
    @builder = Builder::Rotating.new(@writer, options)
    instance_eval(&block) if block
    @builder.close!
  end
  module_function :generate

  def add(path, attrs = {})
    @builder.add(path, attrs)
  end
  module_function :add

  # move to builder???
  def beauty_url(url)
    schema, host = url.scan(/^(https?:\/\/)?(.+?)\/?$/).flatten
    "#{schema || 'http://'}#{host}/"
  end
  module_function :beauty_url
end

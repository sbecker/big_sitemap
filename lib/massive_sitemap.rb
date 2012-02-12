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
    # global
    :index_base_url  => nil,
    :gzip            => false,
    :writer          => MassiveSitemap::Writer::File,

    # writer
    :document_full   => '.',
    :force_overwrite => false,
    :filename        => "sitemap.xml",
    :index_filename  => "sitemap_index.xml",

    # builder
    :base_url        => nil,
    :indent_by       => 2,
  }

  def generate(options = {}, &block)
    @options = DEFAULTS.merge options

    unless @options[:base_url]
      raise ArgumentError, 'you must specify ":base_url" string'
    end
    @options[:index_base_url] ||= @options[:base_url]

    Dir.mkdir(@options[:document_full]) unless ::File.exists?(@options[:document_full])

    @options[:writer] = MassiveSitemap::Writer::GzipFile if @options[:gzip]

    @writer = @options[:writer].new @options
    Builder::Rotating.generate(@writer, @options, &block)

    @writer.options.merge!(:filename => @options[:index_filename], :force_overwrite => true)
    Builder::Index.generate(@writer, @options.merge(:base_url => @options[:index_base_url]))
  end
  module_function :generate
end

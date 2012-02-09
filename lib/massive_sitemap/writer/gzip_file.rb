require 'zlib'

require "massive_sitemap/writer/file"
# Write into GZipped File

module MassiveSitemap
  module Writer

    class GzipFile < File
      def initialize(file_name_template, options = {})
        super(file_name_template + ".gz", options)
      end

      # API
      def init!
        super
        @stream = ::Zlib::GzipWriter.new(@stream)
      end
    end
  end
end

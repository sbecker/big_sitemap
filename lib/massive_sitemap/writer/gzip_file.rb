require 'zlib'

require "massive_sitemap/writer/file"
# Write into GZipped File

module MassiveSitemap
  module Writer

    class GzipFile < File
      def filename
        @options[:filename] + ".gz"
      end

      # API
      def init!(options = {})
        super
        @stream = ::Zlib::GzipWriter.new(@stream)
      end
    end
  end
end

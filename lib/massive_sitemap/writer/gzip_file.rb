require 'zlib'

require "massive_sitemap/writer/file"
# Write into GZipped File

module MassiveSitemap
  module Writer

    class GzipFile < File
      # API
      def init!(options = {})
        super
        @stream = ::Zlib::GzipWriter.new(@stream)
      end

      private
      def filename
        super + ".gz"
      end

    end
  end
end

require 'zlib'

require "massive_sitemap/writer/file"
# Write into GZipped File

module MassiveSitemap
  module Writer

    class GzipFile < File
      OPTS = File::OPTS

      protected
      def open_stream
        ::Zlib::GzipWriter.new(super)
      end

      private
      def filename
        super + ".gz"
      end
    end
  end
end

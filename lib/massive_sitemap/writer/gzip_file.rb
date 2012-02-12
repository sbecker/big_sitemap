require 'zlib'

require "massive_sitemap/writer/file"
# Write into GZipped File

module MassiveSitemap
  module Writer

    class GzipFile < File
      def open_stream
        ::Zlib::GzipWriter.new(super)
      end

      private
      def filename
        super + ".gz"
      end

      def files
        Dir[::File.join(options[:document_full], "*.xml.gz")]
      end
    end
  end
end

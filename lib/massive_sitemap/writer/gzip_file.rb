# Copyright (c) 2012, SoundCloud Ltd., Tobias Bielohlawek

require 'zlib'
require "massive_sitemap/writer/file"

# MassiveSitemap Writer GzipFile
# Extension to file writer for gzip support

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

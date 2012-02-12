require 'fileutils'
require "massive_sitemap/writer/base"

# Write into File

module MassiveSitemap
  module Writer
    class File < Base

      class FileExistsException < IOError; end

      OPTS = {
        :document_full   => '.',
        :force_overwrite => false,
        :filename        => "sitemap.xml",
        :index_filename  => "sitemap_index.xml",
      }

      def open_stream
        ::File.open(tmp_filename, 'w:ASCII-8BIT')
      end

      def close_stream(stream)
        stream.close
        # Move from tmp_file into acutal file
        ::File.delete(filename) if ::File.exists?(filename)
        ::File.rename(tmp_filename, filename)
      end

      def init?
        if !options[:force_overwrite] && ::File.exists?(filename)
          raise FileExistsException, "Can not create file: #{filename} exits"
        end
        true
      end

      private
      def filename
        ::File.join options[:document_full], options[:filename]
      end

      def tmp_filename
        filename + ".tmp"
      end
    end

  end
end

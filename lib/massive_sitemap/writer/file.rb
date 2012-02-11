require 'fileutils'

# Write into File

module MassiveSitemap
  module Writer
    class File

      class FileExistsException < Exception; end

      OPTS = {
        :document_full   => '.',
        :force_overwrite => false,
        :filename        => "sitemap.xml",
        :index_filename  => "sitemap_index.xml",
      }

      attr_reader :options

      def initialize(options = {})
        @options = OPTS.merge(options)
        @stream  = nil
      end

      # API
      def init!(options = {})
        close! if @stream
        @options = @options.merge(options)
        if @options[:force_overwrite] || !::File.exists?(filename)
          @stream = ::File.open(tmp_filename, 'w:ASCII-8BIT')
        else
          raise FileExistsException, "Can not create file: #{filename} exits"
        end
      end

      def close!
        if @stream
          @stream.close
          @stream = nil
          # Move from tmp_file into acutal file
          ::File.delete(filename) if ::File.exists?(filename)
          ::File.rename(tmp_filename, filename)
        end
      end

      def print(string)
        @stream.print(string)
      end

      private
      def filename
        ::File.join @options[:document_full], @options[:filename]
      end

      def tmp_filename
        filename + ".tmp"
      end
    end

  end
end

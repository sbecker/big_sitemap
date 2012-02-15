require 'fileutils'
require 'massive_sitemap/writer/base'

# Write into File

module MassiveSitemap
  module Writer
    class File < Base

      class FileExistsException < IOError; end

      OPTS = Base::OPTS.merge(
        :root            => '.',
        :force_overwrite => false,
        :filename        => "sitemap.xml",
      )

      def initialize(options = {})
        super
        @stream_ids = {}
        Dir[::File.join(@options[:root], "*#{::File.extname(filename)}")].each do |path|
          add_stream_id(path)
        end
      end

      protected
      def open_stream
        #create dir if not exists
        @stream_id = filename
        ::File.dirname(tmp_filename).tap do |dir|
          FileUtils.mkdir_p(dir) unless ::File.exists?(dir)
        end
        ::File.open(tmp_filename, 'w:ASCII-8BIT')
      end

      def close_stream(file)
        file.close
        # Move from tmp_file into acutal file
        ::File.delete(filename) if ::File.exists?(filename)
        ::File.rename(tmp_filename, filename)
        add_stream_id(filename)
        rotate
      end

      def init?
        if !@options[:force_overwrite] && find_stream_id(filename)
          error_message = "Can not create file: #{filename} exits"
          rotate #push next possible filename
          raise FileExistsException, error_message
        end
        true
      end

      # Keep state of Files
      def find_stream_id(path)
        @stream_ids.keys.include?(::File.basename(path))
      end

      def add_stream_id(path)
        @stream_ids[::File.basename(path)] = ::File.stat(path).mtime
      end

      def stream_id
        @stream_id && ::File.basename(@stream_id)
      end

      private
      def filename
        ::File.join @options[:root], @options[:filename]
      end

      def tmp_filename
        filename + ".tmp"
      end

      def rotate
        @options[:filename] = with_rotation(@options[:filename])
      end

      def with_rotation(filename)
        filename, rotation, ext = split_filename(filename)
        [filename, "-", rotation.to_i + 1, ext].join
      end

      def split_filename(filename)
        filename.to_s.scan(/^([^.]*?)(?:-([0-9]+))?(\..+)?$/).flatten
      end
    end

  end
end

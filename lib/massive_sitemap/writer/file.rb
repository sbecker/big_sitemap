require 'fileutils'

# Write into File
# On rotation, close current file, and reopen a new one
# with same file name but -<counter> appendend
#
# TODO what if file exists?, overwrite flag??

module MassiveSitemap
  module Writer
    class File

      class FileExistsException < Exception; end

      OPTS = {
        :document_full => '.',
        :force_overwrite => false,
      }

      attr_reader :options

      def initialize(file_name_template, options = {})
        @stream_name_template = file_name_template
        @options              = OPTS.merge(options)
        @stream_names         = []
        @stream               = nil
      end

      def document_full
        ::File.dirname (@stream_name_template)
      end

      # API
      def init!
        close! if @stream
        if @options[:force_overwrite] || !::File.exists?(file_name)
          @stream = ::File.open(tmp_file_name, 'w:ASCII-8BIT')
        else
          raise FileExistsException, "Can not create file: #{file_name} exits"
        end
      end

      def close!
        @stream.close
        @stream = nil
        # Move from tmp_file into acutal file
        ::File.delete(file_name) if ::File.exists?(file_name)
        ::File.rename(tmp_file_name, file_name)
        @stream_names << file_name
      end

      def print(string)
        @stream.print(string)
      end

      private
      def file_name
        cnt = @stream_names.size == 0 ? "" : "-#{@stream_names.size}"
        ext = ::File.extname(@stream_name_template)
        ::File.join options[:document_full], @stream_name_template.gsub(ext, cnt + ext)
      end

      def tmp_file_name
        file_name + ".tmp"
      end
    end

  end
end

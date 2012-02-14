require "massive_sitemap/builder/base"
# writer only has print and puts as interface

module MassiveSitemap
  module Builder
    class Rotating < Base
      NUM_URLS = 1..50_000

      OPTS = Base::OPTS.merge(
        :max_urls => NUM_URLS.max
      )

      def initialize(writer, options = {}, &block)
        @rotations = 0
        @urls      = 0

        super
      end

      # On rotation, close current file, and reopen a new one
      # with same file name but -<counter> appendend
      def init_writer!(writer_options = {})
        unless @writer.inited?
          filename = filename_with_rotation(@writer.options[:filename], @rotations)
          @rotations += 1
          super(writer_options.merge(:filename => filename))
        end
      end

      def add_url!(location, attrs = {})
        if @urls >= @options[:max_urls]
          close!
          @urls = 0
        end
        super
        @urls += 1
      end

      private
      def filename_with_rotation(filename, rotation = nil)
        filename, _, ext = split_filename(filename)
        rotation = (rotation.to_i > 0) ? "-#{rotation}" : nil
        [filename, rotation, ext].join
      end

      def split_filename(filename)
        filename.to_s.scan(/^([^.]*?)(-[0-9]+)?(\..+)?$/).flatten
      end
    end
  end
end

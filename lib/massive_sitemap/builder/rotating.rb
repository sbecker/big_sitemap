require "massive_sitemap/builder/base"
# writer only has print and puts as interface

module MassiveSitemap
  module Builder
    class Rotating < Base
      NUM_URLS = 1..50_000

      def initialize(writer, options = {}, &block)
        @max_urls  = options[:max_per_sitemap] || NUM_URLS.max
        @rotations = 0

        unless NUM_URLS.member?(@max_urls)
          raise ArgumentError, %Q(":max_per_sitemap" must be greater than #{NUM_URLS.min} and smaller than #{NUM_URLS.max})
        end

        super
      end

      # On rotation, close current file, and reopen a new one
      # with same file name but -<counter> appendend
      def init!(&block) #_init_document
        @urls = 0
        filename = filename_with_rotation(@writer.options[:filename], @rotations)
        @writer.init! :filename => filename
        header!(&block)
      end

      def close!(indent = true)
        super
        @rotations += 1
      end

      def add_url!(location, attrs = {})
        if @urls >= @max_urls
          close!
          init!
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

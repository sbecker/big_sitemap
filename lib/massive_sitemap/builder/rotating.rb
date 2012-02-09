require "massive_sitemap/builder/base"
# writer only has print and puts as interface

module MassiveSitemap
  module Builder
    class Rotating < Base
      NUM_URLS = 1..50_000

      def initialize(writer, options = {}, &block)
        @max_urls = options[:max_per_sitemap] || NUM_URLS.max
        unless NUM_URLS.member?(@max_urls)
          raise ArgumentError, %Q(":max_per_sitemap" must be greater than #{NUM_URLS.min} and smaller than #{NUM_URLS.max})
        end

        super
      end

      def init!(&block)
        @urls = 0
        super
      end

      def add_url!(location, attrs = {})
        if @urls >= @max_urls
          close!
          init!
        end
        super
        @urls += 1
      end
    end
  end
end

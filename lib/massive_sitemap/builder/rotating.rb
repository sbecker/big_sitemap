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
        @urls      = 0

        super
      end

      def add_url!(location, attrs = {})
        if @urls >= @options[:max_urls]
          close!
          @urls = 0
        end
        super
        @urls += 1
      end
    end
  end
end

# Copyright (c) 2012, SoundCloud Ltd., Tobias Bielohlawek

require "massive_sitemap/builder/base"

module MassiveSitemap
  module Builder
    class Rotating < Base
      NUM_URLS = 1..50_000

      OPTS = Base::OPTS.merge(
        :max_urls => NUM_URLS.max
      )

      def header!(&block)
        @urls  = 0
        super
      end

      def add_url!(location, attrs = {})
        if @urls.to_i >= @options[:max_urls]
          close!
        end
        super
        @urls += 1
      end
    end
  end
end

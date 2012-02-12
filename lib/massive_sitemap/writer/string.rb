require 'stringio'
require "massive_sitemap/writer/base"

# Write into String
# Perfect for testing porpuses
module MassiveSitemap
  module Writer

    class String < Base

      def open_stream
        @string ||= StringIO.new
      end

      def to_s
        @string.string rescue ""
      end

      def ==(other_string)
        to_s == other_string
      end

      def include?(other_string)
        to_s.include?(other_string)
      end
    end

  end
end

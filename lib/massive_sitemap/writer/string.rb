require 'stringio'

# Write into String
# Perfect for testing porpuses

module MassiveSitemap
  module Writer

    class String < StringIO
      attr_reader :options

      # API
      def init! # do noting
      end

      def close! # do noting
      end
    end

  end
end

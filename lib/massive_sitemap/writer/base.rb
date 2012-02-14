
module MassiveSitemap
  module Writer
    class Base
      OPTS = {}

      def initialize(options = {})
        @options = self.class::OPTS.merge(options)
        @stream  = nil
      end

      # API
      def init!(options = {})
        @options.merge!(options)
        if init?
          @stream = open_stream
        end
      end

      def close!
        if inited?
          close_stream(@stream)
          @stream = nil
        end
      end

      def inited?
        @stream
      end

      def print(string)
        @stream.print(string) if inited?
      end

      def each(&block)
        stream_ids.each(&block)
      end

      def current
        stream_id
      end

      # Interface
      protected
      def open_stream
        @string ||= StringIO.new
      end

      def close_stream(stream)
      end

      def init?
        true
      end

      def stream_ids
        @stream_ids ||= []
      end

      def stream_id
        nil
      end
    end

  end
end

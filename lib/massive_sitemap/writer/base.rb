# Copyright (c) 2012, SoundCloud Ltd., Tobias Bielohlawek

# MassiveSitemap Writer
# The purpose of a writer is to store the written data, and to keep the state of existing data.
# It offers an API to which a builder can talk to, and a Interface which other writers have to implement
#
module MassiveSitemap
  module Writer
    class Base
      OPTS = {}

      def initialize(options = {})
        @options = self.class::OPTS.merge(options)
        @stream  = nil
      end

      #
      # API to which a builder talks to
      #
      # update wirter options, e.g. filename or overwrite behavior
      def set(options)
        @options.merge!(options)
        self
      end

      # init writer: try to open stream (e.g. file)
      def init!(options = {})
        set(options)
        if init?
          @stream = open_stream
        end
      end

      # close writer (e.g store file)
      def close!
        if inited?
          close_stream(@stream)
          @stream = nil
        end
      end

      # keep status of stream
      def inited?
        @stream
      end

      # write to stream
      def print(string)
        @stream.print(string) if inited?
      end

      def each(&block)
        stream_ids.each(&block)
      end

      def current
        stream_id
      end


      #
      # Interface which other writers have to implement
      #
      protected
      def open_stream
        @string ||= StringIO.new
      end

      def close_stream(stream)
      end

      # whether if stream can be inited, likely to throw an error
      # (e.g. on file existence)
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

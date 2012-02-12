require 'zlib'

require "massive_sitemap/writer/file"
# Create Lock before writing to file

module MassiveSitemap
  module Writer

    class LockingFile < File
      LOCK_FILE = 'generator.lock'

      def open_stream
        ::File.open(LOCK_FILE, 'w', ::File::EXCL) #lock!
        super
      end

      def close_stream(stream)
        super
        FileUtils.rm(LOCK_FILE) #unlock!
      end

      def init?
        if ::File.exists?(LOCK_FILE)
          raise Errno::EACCES
        end
        super
      end
    end

  end
end

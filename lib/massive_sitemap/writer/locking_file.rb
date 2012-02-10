require 'zlib'

require "massive_sitemap/writer/file"
# Create Lock before writing to file

module MassiveSitemap
  module Writer

    class LockingFile < File
        LOCK_FILE = 'generator.lock'

        def init!(options = {})
          close! if @stream
          if ::File.exists?(LOCK_FILE)
            raise Errno::EACCES
          else
            @lock_file = ::File.open(LOCK_FILE, 'w', ::File::EXCL) #lock!
            super
          end
        rescue Errno::EACCES => e
          raise 'Lockfile exists'
        end

        def close!
          super
          FileUtils.rm(LOCK_FILE) if @lock_file #unlock!
        end
      end

  end
end

require 'zlib'

require "massive_sitemap/writer/file"
# Create Lock before writing to file

module MassiveSitemap
  module Writer

    class LockingFile < File
        LOCK_FILE = 'generator.lock'

        def init!(options = {})
          close!
          if ::File.exists?(LOCK_FILE)
            raise Errno::EACCES
          else
            ::File.open(LOCK_FILE, 'w', ::File::EXCL) #lock!
            super
          end
        rescue Errno::EACCES => e
          raise 'Lockfile exists'
        end

        def close!
          if super
            FileUtils.rm(LOCK_FILE) #unlock!
          end
        end
      end

  end
end

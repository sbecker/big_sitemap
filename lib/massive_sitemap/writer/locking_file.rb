require 'zlib'

require "massive_sitemap/writer/file"
# Create Lock before writing to file

module MassiveSitemap
  module Writer

    class LockingFile < File
        LOCK_FILE = 'generator.lock'

        def init!
          close! if @stream
          ::File.open(LOCK_FILE, 'w', ::File::EXCL) #lock!
          super
        rescue Errno::EACCES => e
          raise 'Lockfile exists'
        end

        def close!
          super
          FileUtils.rm LOCK_FILE #unlock!
        end
      end

  end
end

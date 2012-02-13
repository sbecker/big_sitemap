require 'fileutils'

# Create Lock

module MassiveSitemap
  LOCK_FILE = 'generator.lock'

  def lock!(&block)
    if block
      raise Errno::EACCES if ::File.exists?(LOCK_FILE)
      ::File.open(LOCK_FILE, 'w', ::File::EXCL)
      begin
        block.call
      ensure
        FileUtils.rm(LOCK_FILE) #unlock!
      end
    end
  end
  module_function :lock!
end

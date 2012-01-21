require 'fileutils'
require 'zlib'
require 'stringio'

class BigSitemap

  # Write into String
  # Perfect for testing porpuses
  class StringWriter < StringIO
    def rotate # do noting
    end
  end

  # Write into File
  # On rotation, close current file, and reopen a new one
  # with same file name but -<counter> appendend
  #
  # TODO what if file exists?, overwrite flag??
  class FileWriter
    # API
    def rotate
      close if @file
      @file = File.open(tmp_file_name, 'w+:ASCII-8BIT')
    end

    def print(string)
      @file.print(string)
    end

    ###

    def initialize(file_name_template)
      @file_name_template = file_name_template
      @file_names = []
      self.rotate
    end

    def close
      @file.close
      # Move from tmp_file into acutal file
      File.delete(file_name) if File.exists?(file_name)
      File.rename(tmp_file_name, file_name)
      @file_names << file_name
    end

    private
    def file_name
      cnt = @file_names.size == 0 ? "" : "-#{@file_names.size}"
      ext = File.extname(@file_name_template)
      @file_name_template.gsub(ext, cnt + ext)
    end

    def tmp_file_name
      file_name + ".tmp"
    end
  end

  # Write into GZipped File
  class GzipFileWriter < FileWriter
    def initialize(file_name_template)
      super(file_name_template + ".gz")
    end

    def rotate
      super
      @file = ::Zlib::GzipWriter.new(@file)
    end
  end

  class LockingFileWriter < FileWriter
    LOCK_FILE = 'generator.lock'

    def rotate
      close if @file
      File.open(LOCK_FILE, 'w', File::EXCL) #lock!
      @file = File.open(tmp_file_name, 'w+:ASCII-8BIT')
    rescue Errno::EACCES => e
      raise 'Lockfile exists'
    end

    def print(string)
      @file.print(string)
    end

    def close
      FileUtils.rm lock_file #unlock!
      super
    end
  end

end
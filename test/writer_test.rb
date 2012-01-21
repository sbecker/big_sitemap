require File.dirname(__FILE__) + '/test_helper'

class BuilderTest < Test::Unit::TestCase

  ###### FileWriter
  should 'wrong template' do
   file_name = 'test'
   file = BigSitemap::FileWriter.new(file_name)
  end

  should 'create file' do
    begin
      file_name = 'test.txt'
      file = BigSitemap::FileWriter.new(file_name)
      file.close
      assert File.exists?(file_name)
    ensure
      FileUtils.rm file_name
    end
  end

  should 'create second file on rotation' do
    begin
      file_name = 'test.txt'
      file_name2 = 'test-1.txt'
      file = BigSitemap::FileWriter.new(file_name)
      file.rotate
      file.close
      assert File.exists?(file_name)
      assert File.exists?(file_name2)
    ensure
      FileUtils.rm file_name
      FileUtils.rm file_name2
    end
  end

  should 'write into file' do
    begin
      file_name = 'test.txt'
      file = BigSitemap::FileWriter.new(file_name)
      file.print 'test'
      file.close
      assert_equal "test", `cat '#{file_name}'`
    ensure
      FileUtils.rm file_name
    end
  end

  should 'write into second file' do
    begin
      file_name = 'test.txt'
      file_name2 = 'test-1.txt'
      file = BigSitemap::FileWriter.new(file_name)
      file.print 'test'
      file.rotate
      file.print 'test2'
      file.close
      assert_equal "test2", `cat '#{file_name2}'`
    ensure
      FileUtils.rm file_name
      FileUtils.rm file_name2
    end
  end

end

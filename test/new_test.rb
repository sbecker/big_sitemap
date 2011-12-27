require File.dirname(__FILE__) + '/test_helper'
require 'nokogiri'

class BigSitemapTest < Test::Unit::TestCase
  
  ###### arguments
  should 'fail if no base_url given' do
    assert_raise(ArgumentError) do
      BigSitemap.generate
    end
  end

  should 'initalize' do
    assert BigSitemap.generate(:base_url => 'test.de/')
  end

  #todo test: min/max values of max_per_sitemap

  #### lock
  should 'create lockfile' do
    BigSitemap.generate(:base_url => 'test.de/') do
      assert File.exists?(BigSitemap::LOCK_FILE)
    end
    assert !File.exists?(BigSitemap::LOCK_FILE)
  end

  should 'fail if lockfile exists' do
    begin
      File.open(BigSitemap::LOCK_FILE, 'w', File::EXCL)
      assert_raise(RuntimeError) do
        BigSitemap.generate(:base_url => 'test.de/')
      end
    ensure
      FileUtils.rm BigSitemap::LOCK_FILE
    end
  end
  
  #### generate
  should 'add url' do
    BigSitemap.generate(:base_url => 'test.de') do
      add "/test"
    end
  end

end
require File.dirname(__FILE__) + '/test_helper'
require 'nokogiri'

class BigSitemapTest < Test::Unit::TestCase

  #todo test: min/max values of max_per_sitemap

  #### generate
  should 'add url' do
    BigSitemap.generate(:base_url => 'test.de') do
      add "/test"
    end
  end

end
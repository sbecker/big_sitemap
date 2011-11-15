require File.dirname(__FILE__) + '/test_helper'
require 'nokogiri'

class BigSitemapTest < Test::Unit::TestCase
  def setup
    delete_tmp_files
  end

  def teardown
    delete_tmp_files
  end

  should 'raise an error if the :base_url option is not specified' do
    assert_nothing_raised { BigSitemap.new(:base_url => 'http://example.com', :document_root => tmp_dir) }
    assert_raise(ArgumentError) { BigSitemap.new(:document_root => tmp_dir) }
  end

  should 'generate the same base URL with :base_url option' do
    options = {:document_root => tmp_dir}
    url = 'http://example.com'
    sitemap = BigSitemap.new(options.merge(:base_url => url))

    assert_equal url, sitemap.instance_variable_get(:@options)[:base_url]
  end

  should 'generate the same base URL with :url_options option' do
    options = {:document_root => tmp_dir}
    url = 'http://example.com'
    sitemap = BigSitemap.new(options.merge(:url_options => {:host => 'example.com'}))

    assert_equal url, sitemap.instance_variable_get(:@options)[:base_url]
  end

  should 'generate sitemap index file' do
    generate_sitemap { add '/foo' }
    assert File.exists? first_sitemap_file
  end

  should 'generate static file' do
    generate_sitemap { add '/foo' }
    assert File.exists? first_sitemap_file
  end

  should 'should add paths' do
    generate_sitemap do
      add '/', {:last_modified => Time.now, :change_frequency => 'weekly', :priority => 0.5}
      add '/about', {:last_modified => Time.now, :change_frequency => 'weekly', :priority => 0.5}
    end

    elems = elements first_sitemap_file, 'loc'
    assert_equal 'http://example.com/', elems.first.text
    assert_equal 'http://example.com/about', elems.last.text
  end

  context 'Sitemap index file' do
    should 'contain one sitemapindex element' do
      generate_sitemap { add '/' }
      assert_equal 1, num_elements(sitemaps_index_file, 'sitemapindex')
    end

    should 'contain one sitemap element' do
      generate_sitemap { add '/' }  
      assert_equal 1, num_elements(sitemaps_index_file, 'sitemap')
    end

    should 'contain one loc element' do
      generate_sitemap { add '/' }  
      assert_equal 1, num_elements(sitemaps_index_file, 'loc')
    end

    should 'contain one lastmod element' do
      generate_sitemap { add '/' }  
      assert_equal 1, num_elements(sitemaps_index_file, 'lastmod')
    end

    should 'contain two loc elements' do
      generate_sitemap(:max_per_sitemap => 2) do
        4.times { add '/' }
      end

      assert_equal 2, num_elements(sitemaps_index_file, 'loc')
    end

    should 'contain two lastmod elements' do
      generate_sitemap(:max_per_sitemap => 2) do
        4.times { add '/' }
      end

      assert_equal 2, num_elements(sitemaps_index_file, 'lastmod')
    end

    should 'not be gzipped' do
      generate_sitemap(:gzip => false) { add '/' }
      assert File.exists?(unzipped_sitemaps_index_file)
    end
  end

  context 'Sitemap file' do
    should 'contain one urlset element' do
      generate_sitemap { add '/' }
      assert_equal 1, num_elements(first_sitemap_file, 'urlset')
    end

    should 'contain several loc elements' do
      generate_sitemap do
        3.times { add '/' }
      end

      assert_equal 3, num_elements(first_sitemap_file, 'loc')
    end

    should 'contain several lastmod elements' do
      generate_sitemap do
        3.times { add '/', :last_modified => Time.now }
      end

      assert_equal 3, num_elements(first_sitemap_file, 'lastmod')
    end

    should 'contain several changefreq elements' do
      generate_sitemap do
        3.times { add '/' }
      end

      assert_equal 3, num_elements(first_sitemap_file, 'changefreq')
    end

    should 'contain several priority elements' do
      generate_sitemap do
        3.times { add '/', :priority => 0.2 }
      end

      assert_equal 3, num_elements(first_sitemap_file, 'priority')
    end

    should 'have a change frequency of weekly by default' do
      generate_sitemap do
        3.times { add '/' }
      end

      assert_equal 'weekly', elements(first_sitemap_file, 'changefreq').first.text
    end

    should 'have a change frequency of daily' do
      generate_sitemap { add '/', :change_frequency => 'daily' }
      assert_equal 'daily', elements(first_sitemap_file, 'changefreq').first.text
    end

    should 'have a priority of 0.2' do
      generate_sitemap { add '/', :priority => 0.2 }
      assert_equal '0.2', elements(first_sitemap_file, 'priority').first.text
    end

    should 'contain two loc element' do
      generate_sitemap(:max_per_sitemap => 2) do
        4.times { add '/' }
      end

      assert_equal 2, num_elements(first_sitemap_file, 'loc')
      assert_equal 2, num_elements(second_sitemap_file, 'loc')
    end

    should 'contain two changefreq elements' do
      generate_sitemap(:max_per_sitemap => 2) do
        4.times { add '/' }
      end

      assert_equal 2, num_elements(first_sitemap_file, 'changefreq')
      assert_equal 2, num_elements(second_sitemap_file, 'changefreq')
    end

    should 'contain two priority element' do
      generate_sitemap(:max_per_sitemap => 2) do
        4.times { add '/', :priority => 0.2 }
      end

      assert_equal 2, num_elements(first_sitemap_file, 'priority')
      assert_equal 2, num_elements(second_sitemap_file, 'priority')
    end

    should 'not be gzipped' do
      generate_sitemap(:gzip => false) { add '/' }
      assert File.exists?(unzipped_first_sitemap_file)
    end
  end

  context 'sanatize XML chars' do
    should 'should transform ampersands' do
      generate_sitemap { add '/something&else' }
      elems = elements(first_sitemap_file, 'loc')

      assert Zlib::GzipReader.open(first_sitemap_file).read.include?("/something&amp;else")
      assert_equal 'http://example.com/something&else', elems.first.text
    end
  end

  context 'clean method' do
    should 'be chainable' do
      sitemap = generate_sitemap { add '/' }
      assert_equal BigSitemap, sitemap.clean.class
    end

    should 'clean all sitemap files' do
      sitemap = generate_sitemap { add '/' }
      assert Dir["#{sitemaps_dir}/sitemap*"].size > 0, "#{sitemaps_dir} has sitemap files"
      sitemap.clean
      assert_equal 0, Dir["#{sitemaps_dir}/sitemap*"].size, "#{sitemaps_dir} is empty of sitemap files"
    end
  end

  context 'sitemap index' do
    should 'generate for all xml files in directory' do
      sitemap = generate_sitemap {}
      File.open("#{sitemaps_dir}/sitemap_file1.xml", 'w')
      File.open("#{sitemaps_dir}/sitemap_file2.xml.gz", 'w')
      File.open("#{sitemaps_dir}/sitemap_file3.txt", 'w')
      File.open("#{sitemaps_dir}/file4.xml", 'w')
      File.open(unzipped_sitemaps_index_file, 'w')
      sitemap.send :generate_sitemap_index

      elem = elements(sitemaps_index_file, 'loc')
      assert_equal 2, elem.size #no index and file3 and file4 found
      assert_equal "http://example.com/sitemap_file1.xml", elem.first.text
      assert_equal "http://example.com/sitemap_file2.xml.gz", elem.last.text
    end

    should 'generate for all for given file' do
      sitemap = generate_sitemap {}
      File.open("#{sitemaps_dir}/sitemap_file1.xml", 'w')
      File.open("#{sitemaps_dir}/sitemap_file2.xml.gz", 'w')
      files = ["#{sitemaps_dir}/sitemap_file1.xml", "#{sitemaps_dir}/sitemap_file2.xml.gz"]
      sitemap.send :generate_sitemap_index, files

      elem = elements(sitemaps_index_file, 'loc')
      assert_equal 2, elem.size
      assert_equal "http://example.com/sitemap_file1.xml", elem.first.text
      assert_equal "http://example.com/sitemap_file2.xml.gz", elem.last.text
    end
  end


end

require File.dirname(__FILE__) + '/test_helper'

class BuilderTest < Test::Unit::TestCase
  HEADER = %Q(<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">)

  ###### arguments
  should 'fail if writer given' do
    assert_raise(ArgumentError) do
      BigSitemap::Builder.new
    end
  end

  #in sequence
  should 'seq: generate basic skeleton, opened' do
    BigSitemap::Builder.new(is = BigSitemap::StringWriter.new)
    expect = HEADER
    assert_equal expect, is
  end

  should 'generate basic skeleton' do
    bs = BigSitemap::Builder.new(is = BigSitemap::StringWriter.new)
    bs.close!
    expect = %Q(#{HEADER}\n</urlset>)
    assert_equal expect, is
  end

  should 'seq: generate one url' do
    bs = BigSitemap::Builder.new(is = BigSitemap::StringWriter.new)
    bs.add_url! 'test'
    bs.close!
    expect = %Q(#{HEADER}\n  <url>\n    <loc>test</loc>\n  </url>\n</urlset>)
    assert_equal expect, is
  end

  #as block
  should 'generate basic skeleton' do
    BigSitemap::Builder.new(is = BigSitemap::StringWriter.new) do
    end
    expect = %Q(#{HEADER}\n</urlset>)
    assert_equal expect, is
  end

  should 'generate one url' do
    BigSitemap::Builder.new(is = BigSitemap::StringWriter.new) do
      add_url! 'test'
    end
    expect = %Q(#{HEADER}\n  <url>\n    <loc>test</loc>\n  </url>\n</urlset>)
    assert_equal expect, is
  end

  should 'generate one url, no indent' do
    BigSitemap::Builder.new(is = BigSitemap::StringWriter.new, :indent_by => 0) do
      add_url! 'test'
    end
    expect = %Q(#{HEADER}\n<url>\n<loc>test</loc>\n</url>\n</urlset>)
    assert_equal expect, is
  end

  should 'generate two url' do
    BigSitemap::Builder.new(is = BigSitemap::StringWriter.new) do
      add_url! 'test'
      add_url! 'test2'
    end
    expect = %Q(#{HEADER}\n  <url>\n    <loc>test</loc>\n  </url>\n  <url>\n    <loc>test2</loc>\n  </url>\n</urlset>)
    assert_equal expect, is
  end

  should 'generate one url with attrs' do
    BigSitemap::Builder.new(is = BigSitemap::StringWriter.new) do
      add_url! 'test', :change_frequency => 'weekly', :priority => 0.8
    end
    expect = <<-XML
#{HEADER}
  <url>
    <loc>test</loc>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>
</urlset>
XML
    assert_equal expect.strip, is
  end

  ########## IndexBuilder
  INDEX_HEADER = %Q(<?xml version="1.0" encoding="UTF-8"?>\n<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n<sitemap>)

  should 'Index: generate one url' do
    BigSitemap::IndexBuilder.new(is = BigSitemap::StringWriter.new, :indent_by => 0) do
      add_url! 'test'
    end
    expect = %Q(#{INDEX_HEADER}\n<loc>test</loc>\n</sitemap>\n</sitemapindex>)
    assert_equal expect, is
  end

  ########## RotatingBuilder
  should 'RotatingBuilder: generate one url' do
    BigSitemap::RotatingBuilder::MAX_URLS = 1
    BigSitemap::RotatingBuilder.new(is = BigSitemap::StringWriter.new) do
      add_url! 'test'
    end
    expect = %Q(#{HEADER}\n  <url>\n    <loc>test</loc>\n  </url>\n</urlset>)
    assert_equal expect, is
  end

  should 'RotatingBuilder: generate two url' do
    BigSitemap::RotatingBuilder::MAX_URLS = 1
    BigSitemap::RotatingBuilder.new(is = BigSitemap::StringWriter.new) do
      add_url! 'test'
      add_url! 'test2'
    end
    expect = %Q(#{HEADER}\n  <url>\n    <loc>test</loc>\n  </url>\n</urlset>#{HEADER}\n  <url>\n    <loc>test2</loc>\n  </url>\n</urlset>)
    assert_equal expect, is
  end
end
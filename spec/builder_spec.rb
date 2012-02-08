require "spec_helper"

describe BigSitemap::Builder do
  HEADER = %Q(<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">)

  describe "#arguments" do
    it 'fail if writer given' do
      expect do
        BigSitemap::Builder.new
      end.to raise_error(ArgumentError)
    end
  end

  context "in sequence" do
    it 'seq: generate basic skeleton, opened' do
      BigSitemap::Builder.new(is = BigSitemap::StringWriter.new)
      is.string.should == HEADER
    end

    it 'generate basic skeleton' do
      bs = BigSitemap::Builder.new(is = BigSitemap::StringWriter.new)
      bs.close!
      is.string.should == %Q(#{HEADER}\n</urlset>)
    end

    it 'seq: generate one url' do
      bs = BigSitemap::Builder.new(is = BigSitemap::StringWriter.new)
      bs.add_url! 'test'
      bs.close!
      is.string.should == %Q(#{HEADER}\n  <url>\n    <loc>test</loc>\n  </url>\n</urlset>)
    end
  end

  context "as block" do
    it 'generate basic skeleton' do
      BigSitemap::Builder.new(is = BigSitemap::StringWriter.new) do
      end
      is.string.should == %Q(#{HEADER}\n</urlset>)
    end

    it 'generate one url' do
      BigSitemap::Builder.new(is = BigSitemap::StringWriter.new) do
        add_url! 'test'
      end
      is.string.should == %Q(#{HEADER}\n  <url>\n    <loc>test</loc>\n  </url>\n</urlset>)
    end

    it 'generate one url, no indent' do
      BigSitemap::Builder.new(is = BigSitemap::StringWriter.new, :indent_by => 0) do
        add_url! 'test'
      end
      is.string.should == %Q(#{HEADER}\n<url>\n<loc>test</loc>\n</url>\n</urlset>)
    end

    it 'generate two url' do
      BigSitemap::Builder.new(is = BigSitemap::StringWriter.new) do
        add_url! 'test'
        add_url! 'test2'
      end
      is.string.should == %Q(#{HEADER}\n  <url>\n    <loc>test</loc>\n  </url>\n  <url>\n    <loc>test2</loc>\n  </url>\n</urlset>)
    end

    it 'generate one url with attrs' do
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
      is.string.should == expect.strip
    end
  end
end

describe BigSitemap::IndexBuilder do
  INDEX_HEADER = %Q(<?xml version="1.0" encoding="UTF-8"?>\n<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n<sitemap>)

  it 'Index: generate one url' do
    BigSitemap::IndexBuilder.new(is = BigSitemap::StringWriter.new, :indent_by => 0) do
      add_url! 'test'
    end
    is.string.should == %Q(#{INDEX_HEADER}\n<loc>test</loc>\n</sitemap>\n</sitemapindex>)
  end
end

describe BigSitemap::RotatingBuilder do
  before do
    BigSitemap::RotatingBuilder.send :remove_const, "MAX_URLS"
    BigSitemap::RotatingBuilder.const_set "MAX_URLS", 1
  end

  it 'RotatingBuilder: generate one url' do
    BigSitemap::RotatingBuilder.new(is = BigSitemap::StringWriter.new) do
      add_url! 'test'
    end
    is.string.should == %Q(#{HEADER}\n  <url>\n    <loc>test</loc>\n  </url>\n</urlset>)
  end

  it 'RotatingBuilder: generate two url' do
    BigSitemap::RotatingBuilder.new(is = BigSitemap::StringWriter.new) do
      add_url! 'test'
      add_url! 'test2'
    end
    is.string.should == %Q(#{HEADER}\n  <url>\n    <loc>test</loc>\n  </url>\n</urlset>#{HEADER}\n  <url>\n    <loc>test2</loc>\n  </url>\n</urlset>)
  end
end
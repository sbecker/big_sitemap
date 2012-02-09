require "spec_helper"

require "massive_sitemap/builder/base"
require "massive_sitemap/writer/string"

describe MassiveSitemap::Builder::Base do
  HEADER = %Q(<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">)

  let(:writer) { MassiveSitemap::Writer::String.new }
  let(:builder) { MassiveSitemap::Builder::Base.new(writer) }

  describe "#arguments" do
    it 'fail if no writer given' do
      expect do
        MassiveSitemap::Builder::Base.new
      end.to raise_error(ArgumentError)
    end
  end

  context "in sequence" do
    it 'seq: generate basic skeleton, opened' do
      builder
      writer.string.should == HEADER
    end

    it 'generate basic skeleton' do
      builder.close!
      writer.string.should == %Q(#{HEADER}\n</urlset>)
    end

    it 'seq: generate one url' do
      builder.add_url! 'test'
      builder.close!
      writer.string.should == %Q(#{HEADER}\n  <url>\n    <loc>test</loc>\n  </url>\n</urlset>)
    end
  end

  context "as block" do
    it 'generate basic skeleton' do
      MassiveSitemap::Builder::Base.new(writer) do
      end
      writer.string.should == %Q(#{HEADER}\n</urlset>)
    end

    it 'generate one url' do
      MassiveSitemap::Builder::Base.new(writer) do
        add_url! 'test'
      end
      writer.string.should == %Q(#{HEADER}\n  <url>\n    <loc>test</loc>\n  </url>\n</urlset>)
    end

    it 'generate one url, no indent' do
      MassiveSitemap::Builder::Base.new(writer, :indent_by => 0) do
        add_url! 'test'
      end
      writer.string.should == %Q(#{HEADER}\n<url>\n<loc>test</loc>\n</url>\n</urlset>)
    end

    it 'generate two url' do
      writer.should_receive(:init!).once
      writer.should_receive(:close!).once
      MassiveSitemap::Builder::Base.new(writer) do
        add_url! 'test'
        add_url! 'test2'
      end
      writer.string.should == %Q(#{HEADER}\n  <url>\n    <loc>test</loc>\n  </url>\n  <url>\n    <loc>test2</loc>\n  </url>\n</urlset>)
    end

    it 'generate one url with attrs' do
      MassiveSitemap::Builder::Base.new(writer) do
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
      writer.string.should == expect.strip
    end
  end
end

####

require "massive_sitemap/builder/index"
describe MassiveSitemap::Builder::Index do
  INDEX_HEADER = %Q(<?xml version="1.0" encoding="UTF-8"?>\n<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n<sitemap>)

  let(:writer) { MassiveSitemap::Writer::String.new }

  it 'Index: generate one url' do
    MassiveSitemap::Builder::Index.new(writer, :indent_by => 0) do
      add_url! 'test'
    end
    writer.string.should == %Q(#{INDEX_HEADER}\n<loc>test</loc>\n</sitemap>\n</sitemapindex>)
  end
end

####

require "massive_sitemap/builder/rotating"
describe MassiveSitemap::Builder::Rotating do

  let(:writer) { MassiveSitemap::Writer::String.new }

  it 'raises error when max_per_sitemap > MAX_URLS' do
    expect do
      MassiveSitemap::Builder::Rotating.new(writer, :max_per_sitemap => MassiveSitemap::Builder::Rotating::NUM_URLS.max + 1)
    end.to raise_error(ArgumentError)
  end

  it 'generates one url' do
    MassiveSitemap::Builder::Rotating.new(writer) do
      add_url! 'test'
    end
    writer.string.should == %Q(#{HEADER}\n  <url>\n    <loc>test</loc>\n  </url>\n</urlset>)
  end

  it 'generates two url' do
    writer.should_receive(:init!).twice
    writer.should_receive(:close!).twice
    MassiveSitemap::Builder::Rotating.new(writer, :max_per_sitemap => 1) do
      add_url! 'test'
      add_url! 'test2'
    end
    writer.string.should == %Q(#{HEADER}\n  <url>\n    <loc>test</loc>\n  </url>\n</urlset>#{HEADER}\n  <url>\n    <loc>test2</loc>\n  </url>\n</urlset>)
  end
end

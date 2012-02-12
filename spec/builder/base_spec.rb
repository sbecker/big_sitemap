require "spec_helper"

require "massive_sitemap/builder"
require "massive_sitemap/writer/string"

describe MassiveSitemap::Builder::Base do
  let(:header) { %Q(<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">) }
  let(:writer) { MassiveSitemap::Writer::String.new }
  let(:builder) { MassiveSitemap::Builder.new(writer) }

  describe "#arguments" do
    it 'fail if no writer given' do
      expect do
        MassiveSitemap::Builder.new
      end.to raise_error(ArgumentError)
    end
  end

  context "no content added" do
    it 'empty per default' do
      builder

      writer.should == ""
    end

    it 'generate basic skeleton' do
      builder.init!
      writer.should == header
    end

    it 'generate basic skeleton on double init' do
      builder.init!
      builder.init!
      writer.should == header
    end

    it 'generate nothing when not inited' do
      builder.close!
      writer.should == ""
    end

    it "same result on double close" do
      builder.close!
      builder.close!
      writer.should == ""
    end

    it "same result on double close" do
      builder.init!
      builder.close!
      builder.close!
      writer.should == %Q(#{header}\n</urlset>)
    end

    it "same result on double close" do
      builder.init! do
        add "test"
      end
      writer.should == %Q(#{header}\n  <url>\n    <loc>/test</loc>\n  </url>\n</urlset>)
    end
  end

  context "adding content" do
    it 'seq: generate one url' do
      builder.add 'test'
      builder.close!
      writer.should == %Q(#{header}\n  <url>\n    <loc>/test</loc>\n  </url>\n</urlset>)
    end
  end

  context "as block" do
    it 'generate basic skeleton' do
      MassiveSitemap::Builder.new(writer)  {}
      writer.should == ""
    end

    it 'generate one url' do
      MassiveSitemap::Builder.new(writer) do
        add 'test'
      end
      writer.should == %Q(#{header}\n  <url>\n    <loc>/test</loc>\n  </url>\n</urlset>)
    end

    it 'generate one url with init!' do
      MassiveSitemap::Builder.new(writer) do
        init!
        add 'test'
      end
      writer.should == %Q(#{header}\n  <url>\n    <loc>/test</loc>\n  </url>\n</urlset>)
    end

    it 'generate one url with init! block' do
      MassiveSitemap::Builder.new(writer) do
        init! do
          add 'test'
        end
      end
      writer.should == %Q(#{header}\n  <url>\n    <loc>/test</loc>\n  </url>\n</urlset>)
    end

    it 'generate one url with close!' do
      MassiveSitemap::Builder.new(writer) do
        add 'test'
        close!
      end
      writer.should == %Q(#{header}\n  <url>\n    <loc>/test</loc>\n  </url>\n</urlset>)
    end

    it 'generate one url, no indent' do
      MassiveSitemap::Builder.new(writer, :indent_by => 0) do
        add_url! 'test'
      end
      writer.should == %Q(#{header}\n<url>\n<loc>test</loc>\n</url>\n</urlset>)
    end

    it 'generate two url' do
      MassiveSitemap::Builder.new(writer) do
        add_url! 'test'
        add_url! 'test2'
      end
      writer.should == %Q(#{header}\n  <url>\n    <loc>test</loc>\n  </url>\n  <url>\n    <loc>test2</loc>\n  </url>\n</urlset>)
    end

    it 'generate one url with attrs' do
      MassiveSitemap::Builder.new(writer, :indent_by => 0) do
        add_url! 'test', :change_frequency => 'weekly', :priority => 0.8
      end
      writer.should include("<loc>test</loc>\n<changefreq>weekly</changefreq>\n<priority>0.8</priority>")
    end
  end

  describe ".base_url" do
    URLS = %w(
      http://test.de/
      test.de/
      test.de
    )

    URLS.each do |url|
      it "transforms to valid url" do
        MassiveSitemap::Builder.new(writer, :base_url => url).send(:base_url).should == "http://test.de/"
      end
    end

    it "transforms to valid url with https" do
      MassiveSitemap::Builder.new(writer, :base_url => "https://test.de/").send(:base_url).should == "https://test.de/"
    end
  end
end

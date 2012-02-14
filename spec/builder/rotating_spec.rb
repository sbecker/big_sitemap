require "spec_helper"

require "massive_sitemap/builder/rotating"
require "massive_sitemap/writer/string"

describe MassiveSitemap::Builder::Rotating do
  let(:header) { %Q(<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">) }
  let(:writer) { MassiveSitemap::Writer::String.new }
  let(:builder) { MassiveSitemap::Builder::Rotating.new(writer) }

  it 'generates one url' do
    MassiveSitemap::Builder::Rotating.new(writer) do
      add_url! 'test'
    end
    writer.should == %Q(#{header}\n  <url>\n    <loc>test</loc>\n  </url>\n</urlset>)
  end

  it 'generates two url' do
    MassiveSitemap::Builder::Rotating.new(writer, :max_urls => 1) do
      add_url! 'test'
      add_url! 'test2'
    end
    writer.should == %Q(#{header}\n  <url>\n    <loc>test</loc>\n  </url>\n</urlset>#{header}\n  <url>\n    <loc>test2</loc>\n  </url>\n</urlset>)
  end

  context "with file" do
    let(:filename) { 'sitemap.xml' }
    let(:filename2) { 'sitemap-1.xml' }
    let(:writer) { MassiveSitemap::Writer::File.new }

    after do
      FileUtils.rm(filename) rescue nil
      FileUtils.rm(filename2) rescue nil
    end

    it 'generates two url' do
      expect do
        expect do
          MassiveSitemap::Builder::Rotating.new(writer, :max_urls => 1) do
            add 'test'
            add 'test2'
          end
        end.to change { File.exists?(filename) }.to(true)
      end.to change { File.exists?(filename2) }.to(true)
    end

    it 'generates two url when file exists' do
      File.open(filename, 'w') {}
      expect do
        expect do
          MassiveSitemap::Builder::Rotating.new(writer, :max_urls => 1) do
            begin
              add 'test'
            rescue MassiveSitemap::Writer::File::FileExistsException => e
            end
            add 'test2'
          end
        end.to_not change { File.exists?(filename) }.from(true)
      end.to change { File.exists?(filename2) }.to(true)
    end
  end

end

require "spec_helper"

require "massive_sitemap/builder/index"
require "massive_sitemap/writer/string"

describe MassiveSitemap::Builder::Index do
  INDEX_HEADER = %Q(<?xml version="1.0" encoding="UTF-8"?>\n<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n<sitemap>)

  let(:writer) { MassiveSitemap::Writer::String.new }

  before do
    writer.stub!(:stream_ids).and_return(['test'])
  end

  it 'generates one url' do
    MassiveSitemap::Builder::Index.new(writer, :indent_by => 0)

    writer.should == %Q(#{INDEX_HEADER}\n<loc>/test</loc>\n</sitemap>\n</sitemapindex>)
  end

  it 'include url' do
    MassiveSitemap::Builder::Index.new(writer, :url => "test.de", :indent_by => 0)
    writer.should include("<loc>http://test.de/test</loc>")
  end

  context "with file writer" do
    let(:index_filename) { "sitemap_index.xml" }
    let(:writer) { MassiveSitemap::Writer::File.new(:filename => index_filename) }

    after do
      FileUtils.rm(index_filename)
    end

    it 'returns index_url' do
      MassiveSitemap::Builder::Index.generate(writer, :url => "test.de").should == "http://test.de/sitemap_index.xml"
    end
  end
end

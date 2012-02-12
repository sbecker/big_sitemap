require "spec_helper"

require "massive_sitemap/builder/index"
require "massive_sitemap/writer/string"

describe MassiveSitemap::Builder::Index do
  INDEX_HEADER = %Q(<?xml version="1.0" encoding="UTF-8"?>\n<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n<sitemap>)

  let(:writer) { MassiveSitemap::Writer::String.new }

  before do
    writer.stub!(:streams).and_return(['test'])
  end

  it 'generates one url' do
    MassiveSitemap::Builder::Index.new(writer, :indent_by => 0)

    writer.should == %Q(#{INDEX_HEADER}\n<loc>/test</loc>\n</sitemap>\n</sitemapindex>)
  end

  it 'include url' do
    MassiveSitemap::Builder::Index.new(writer, :url => "test.de", :indent_by => 0)
    writer.should include("<loc>http://test.de/test</loc>")
  end

  it 'returns index_url' do
    writer = MassiveSitemap::Writer::File.new(:filename => "sitemap_index.xml")
    MassiveSitemap::Builder::Index.generate(writer, :url => "test.de").should == "http://test.de/sitemap_index.xml"
  end
end

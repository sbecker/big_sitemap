require "spec_helper"

require "massive_sitemap/builder/rotating"
require "massive_sitemap/writer/string"

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

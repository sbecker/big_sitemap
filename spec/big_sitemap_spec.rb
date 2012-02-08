require "spec_helper"

describe BigSitemap do

  describe "#initalize" do
    it 'fail if no base_url given' do
      expect do
        BigSitemap.generate
      end.to raise_error(ArgumentError)
    end

    it 'initalize' do
      expect do
        BigSitemap.generate(:base_url => 'test.de/')
      end.to_not raise_error
    end
  end

  describe "#generate" do
    after do
      FileUtils.rm('sitemap.xml') rescue nil
    end

    it 'adds url' do
      expect do
        BigSitemap.generate(:base_url => 'test.de/') do
          add "as"
        end
      end.to_not raise_error
      expect = <<-OUT
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
  <url>
    <loc>as</loc>
  </url>
</urlset>
OUT
      `cat 'sitemap.xml'`.should == expect.strip
    end
  end
end
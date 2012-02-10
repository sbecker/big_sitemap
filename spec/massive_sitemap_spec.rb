require "spec_helper"

require "massive_sitemap/writer/file"

describe MassiveSitemap do
  let(:file_name) { 'sitemap.xml' }
  let(:file_name2) { 'sitemap2.xml' }

  let(:output) { `cat '#{file_name}'` }
  let(:output2) { `cat '#{file_name2}'` }

  after do
    FileUtils.rm(file_name) rescue nil
    FileUtils.rm(file_name2) rescue nil
  end

  describe "#initalize" do
    it 'fail if no base_url given' do
      expect do
        MassiveSitemap.generate
      end.to raise_error(ArgumentError)
    end

    it 'initalize' do
      expect do
        MassiveSitemap.generate(:base_url => 'test.de/')
      end.to_not raise_error
    end

    it 'creates sitemap file' do
      MassiveSitemap.generate(:base_url => 'test.de/')
      ::File.exists?(file_name).should be_true
    end

    context "gziped" do
      let(:gz_file_name) { "#{file_name}.gz" }

      after do
        FileUtils.rm(gz_file_name) rescue nil
      end

      it 'creates sitemap file' do
        MassiveSitemap.generate(:base_url => 'test.de/', :gzip => true)
        ::File.exists?(gz_file_name).should be_true
      end
    end
  end

  describe "#generate" do
    it 'adds url' do
      MassiveSitemap.generate(:base_url => 'test.de') do
        add "track/name"
      end
      output.should include("<loc>http://test.de/track/name</loc>")
    end

    it 'adds url with root slash' do
      MassiveSitemap.generate(:base_url => 'test.de/') do
        add "/track/name"
      end
      output.should include("<loc>http://test.de/track/name</loc>")
    end

    it 'adds url' do
      MassiveSitemap.generate(:base_url => 'test.de/') do
        writer = MassiveSitemap::Writer::File.new "sitemap2.xml", @writer.options
        MassiveSitemap::Builder::Rotating.new(writer, @builder.options) do
          add "/set/name"
        end
      end
      output2.should include("<loc>http://test.de/set/name</loc>")
    end

  end

  describe "#generate_index" do
    let(:index_file) { 'sitemap_index.xml' }
    let(:index_output) { `cat '#{index_file}'` }
    let(:lastmod) { File.stat(index_file).mtime.utc.strftime('%Y-%m-%dT%H:%M:%S+00:00') }

    after do
      FileUtils.rm(index_file) rescue nil
    end

    it 'includes urls' do
      MassiveSitemap.generate(:base_url => 'test.de/') do
        add "/set/name"
      end.generate_index

      index_output.should == <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <sitemap>
    <loc>http://test.de/sitemap.xml</loc>
    <lastmod>#{lastmod}</lastmod>
  </sitemap>
</sitemapindex>
XML
.strip

    end
  end
end

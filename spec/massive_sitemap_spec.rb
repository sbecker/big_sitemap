require "spec_helper"

require "massive_sitemap/writer/gzip_file"

describe MassiveSitemap do
  let(:filename) { 'sitemap.xml' }
  let(:filename2) { 'sitemap2.xml' }

  let(:output) { `cat '#{filename}'` }
  let(:output2) { `cat '#{filename2}'` }

  after do
    FileUtils.rm(filename) rescue nil
    FileUtils.rm(filename2) rescue nil
  end

  describe "#initalize" do
    it 'fail if no base_url given' do
      expect do
        MassiveSitemap.generate
      end.to raise_error(ArgumentError)
    end

    it 'creates sitemap file' do
      MassiveSitemap.generate(:base_url => 'test.de/')
      ::File.exists?(filename).should be_true
    end

    context "gziped" do
      let(:gz_filename) { "#{filename}.gz" }

      after do
        FileUtils.rm(gz_filename) rescue nil
      end

      it 'creates sitemap file' do
        MassiveSitemap.generate(:base_url => 'test.de/', :writer => MassiveSitemap::Writer::GzipFile)
        ::File.exists?(gz_filename).should be_true
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
        writer = @writer.class.new(@options.merge(:filename => "sitemap2.xml"))
        MassiveSitemap::Builder::Rotating.new(writer, @options) do
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

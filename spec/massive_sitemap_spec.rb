require "spec_helper"

require "massive_sitemap/writer/file"

describe MassiveSitemap do

  describe "#initalize" do
    it 'fail if no base_url given' do
      expect do
        MassiveSitemap::generate
      end.to raise_error(ArgumentError)
    end

    it 'initalize' do
      expect do
        MassiveSitemap.generate(:base_url => 'test.de/')
      end.to_not raise_error
    end
  end

  describe "#generate" do
    let(:output) { `cat 'sitemap.xml'` }
    let(:output2) { `cat 'sitemap2.xml'` }

    after do
      FileUtils.rm('sitemap.xml') rescue nil
      FileUtils.rm('sitemap2.xml') rescue nil
    end

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
end


describe MassiveSitemap do

  describe ".beauty_url" do
    URLS = %w(
      http://test.de/
      test.de/
      test.de
    )

    URLS.each do |url|
      it "transforms to valid url" do
        MassiveSitemap.beauty_url(url).should == "http://test.de/"
      end
    end

    it "transforms to valid url with https" do
      MassiveSitemap.beauty_url("https://test.de/").should == "https://test.de/"
    end
  end

end

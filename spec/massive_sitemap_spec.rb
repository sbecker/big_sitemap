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
end

require "spec_helper"

require "massive_sitemap/writer/gzip_file"

describe MassiveSitemap do
  let(:filename) { 'sitemap.xml' }
  let(:filename2) { 'sitemap2.xml' }

  def output(file = filename)
    `cat '#{file}'`
  end

  def gz_filename(file = filename)
    "#{file}.gz"
  end

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

    context 'nested generation' do
      it 'adds url of nested builder' do
        MassiveSitemap.generate(:base_url => 'test.de/') do
          writer = @writer.class.new(@options.merge(:filename => 'sitemap2.xml'))
          MassiveSitemap::Builder::Rotating.new(writer, @options) do
            add "/set/name"
          end
        end
        output(filename2).should include("<loc>http://test.de/set/name</loc>")
      end

      it 'executes block altough first sitemap exists' do
        File.open(filename, 'w') {}
        MassiveSitemap.generate(:base_url => 'test.de/') do
          writer = @writer.class.new(@options.merge(:filename => 'sitemap2.xml'))
          MassiveSitemap::Builder::Rotating.new(writer, @options) do
            add "/set/name"
          end
        end
        output(filename2).should include("<loc>http://test.de/set/name</loc>")
      end
    end

  end

  describe "#generate_index" do
    let(:index_filename) { 'sitemap_index.xml' }
    let(:lastmod) { File.stat(index_filename).mtime.utc.strftime('%Y-%m-%dT%H:%M:%S+00:00') }

    after do
      FileUtils.rm(index_filename) rescue nil
    end

    it 'includes urls' do
      MassiveSitemap.generate(:base_url => 'test.de/', :indent_by => 0).generate_index

      output(index_filename).should include("<sitemap>\n<loc>http://test.de/sitemap.xml</loc>\n<lastmod>#{lastmod}</lastmod>\n</sitemap>")
    end

    it 'includes index base url' do
      MassiveSitemap.generate(:base_url => 'test.de/', :index_base_url => 'index.de/').generate_index

      output(index_filename).should include("<loc>http://index.de/sitemap.xml</loc>")
    end

    it 'overwrites existing one' do
      File.open(index_filename, 'w') {}
      MassiveSitemap.generate(:base_url => 'test.de/', :index_base_url => 'index.de/').generate_index

      output(index_filename).should include("<loc>http://index.de/sitemap.xml</loc>")
    end

    context "gziped" do
      after do
        FileUtils.rm(gz_filename(index_filename)) rescue nil
        FileUtils.rm(gz_filename) rescue nil
      end

      it 'creates sitemap file' do
        MassiveSitemap.generate(:base_url => 'test.de/', :writer => MassiveSitemap::Writer::GzipFile).generate_index
        ::File.exists?(gz_filename(index_filename)).should be_true
      end
    end
  end
end

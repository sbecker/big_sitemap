require "spec_helper"

require "massive_sitemap/writer/gzip_file"

describe MassiveSitemap do
  let(:index_filename) { 'sitemap_index.xml' }
  let(:filename) { 'sitemap.xml' }
  let(:filename2) { 'sitemap2.xml' }

  def output(file = filename)
    `cat '#{file}'`
  end

  def gz_filename(file = filename)
    "#{file}.gz"
  end

  after do
    FileUtils.rm(index_filename) rescue nil
    FileUtils.rm(filename) rescue nil
    FileUtils.rm(filename2) rescue nil
  end

  describe "generate" do
    context "initalize" do
      it 'fail if no url given' do
        expect do
          MassiveSitemap.generate
        end.to raise_error(ArgumentError)
      end

      it 'raises error when max_urls > MAX_URLS' do
        expect do
          MassiveSitemap.generate(:max_urls => MassiveSitemap::Builder::Rotating::NUM_URLS.max + 1)
        end.to raise_error(ArgumentError)
      end

      it "does not create empty sitemap file" do
        expect do
          MassiveSitemap.generate(:url => 'test.de/')
        end.to_not change { ::File.exists?(filename) }
      end

      context "custom writer" do
        after do
          FileUtils.rm(gz_filename(index_filename)) rescue nil
          FileUtils.rm(gz_filename) rescue nil
        end

        it 'takes gzips writer' do
          expect do
            MassiveSitemap.generate(:url => 'test.de/', :gzip => true) do
               add "dummy"
            end
          end.to change { ::File.exists?(gz_filename) }.to(true)
        end

        it 'takes custom writer' do
          expect do
            MassiveSitemap.generate(:url => 'test.de/', :writer => MassiveSitemap::Writer::GzipFile.new) do
              add "dummy"
            end
          end.to change { ::File.exists?(gz_filename) }.to(true)
        end
      end
    end

    context "generate" do
      it 'adds url' do
        MassiveSitemap.generate(:url => 'test.de') do
          add "track/name"
        end
        output.should include("<loc>http://test.de/track/name</loc>")
      end

      it 'adds url with root slash' do
        MassiveSitemap.generate(:url => 'test.de/') do
          add "/track/name"
        end
        output.should include("<loc>http://test.de/track/name</loc>")
      end

      it 'adds url with no tryiling root for domain' do
        MassiveSitemap.generate(:url => 'test.de') do
          add "/track/name"
        end
        output.should include("<loc>http://test.de/track/name</loc>")
      end

      it "to fail for existing file" do
        File.open(filename, 'w') {}
        expect do
          MassiveSitemap.generate(:url => 'test.de/') do
            add "/track/name"
          end
        end.to raise_error(MassiveSitemap::Writer::File::FileExistsException)
      end

      context 'nested generation' do
        let(:generate!) do
          MassiveSitemap.generate(:url => 'test.de/') do
            @writer.set(:filename => 'sitemap2.xml')
            MassiveSitemap::Builder::Rotating.generate(@writer, @options) do
              init_writer!
              add "/set/name"
            end
          end
        end

        it 'adds url of nested builder' do
          generate!

          output(filename2).should include("<loc>http://test.de/set/name</loc>")
        end

        it 'executes block altough first sitemap exists' do
          File.open(filename, 'w') {}
          generate!

          output(filename2).should include("<loc>http://test.de/set/name</loc>")
        end
      end
    end

    context "generate_index" do
      let(:lastmod) { File.stat(index_filename).mtime.utc.strftime('%Y-%m-%dT%H:%M:%S+00:00') }

      it "does not create empty files" do
        expect do
          MassiveSitemap.generate(:url => 'test.de/')
        end.to_not change { ::File.exists?(index_filename) }.from(false)
      end

      it 'includes urls' do
        MassiveSitemap.generate(:url => 'test.de/', :indent_by => 0) do
          add "dummy"
        end

        output(index_filename).should include("<sitemap>\n<loc>http://test.de/sitemap.xml</loc>\n<lastmod>#{lastmod}</lastmod>\n</sitemap>")
      end

      it 'includes index base url' do
        MassiveSitemap.generate(:url => 'test.de/', :index_url => 'index.de/')  do
          add "dummy"
        end

        output(index_filename).should include("<loc>http://index.de/sitemap.xml</loc>")
      end

      it 'overwrites existing one' do
        File.open(index_filename, 'w') {}
        MassiveSitemap.generate(:url => 'test.de/', :index_url => 'index.de/') do
          add "dummy"
        end

        output(index_filename).should include("<loc>http://index.de/sitemap.xml</loc>")
      end

      context "gziped" do
        after do
          FileUtils.rm(gz_filename(index_filename)) rescue nil
          FileUtils.rm(gz_filename) rescue nil
        end

        it 'creates sitemap file' do
          expect do
            MassiveSitemap.generate(:url => 'test.de/', :writer => MassiveSitemap::Writer::GzipFile.new) do
              add "dummy"
            end
          end.to change { ::File.exists?(gz_filename(index_filename)) }.to(true)
        end
      end
    end
  end

  describe "ping" do
    PINGS = [
      "http://www.google.com/webmasters/tools/ping?sitemap=http%3A%2F%2Ftest.de%2Fsitemap_index.xml",
      "http://www.bing.com/webmaster/ping.aspx?siteMap=http%3A%2F%2Ftest.de%2Fsitemap_index.xml",
      "http://webmaster.yandex.ru/wmconsole/sitemap_list.xml?host=http%3A%2F%2Ftest.de%2Fsitemap_index.xml",
    ]

    it 'calls all engines' do
      MassiveSitemap.should_receive(:open).exactly(3).times.with { |arg|
        arg.should == PINGS.shift
      }.and_return(true)

      index_url = MassiveSitemap.generate(:url => 'test.de/') do
        add "dummy"
      end
      MassiveSitemap.ping(index_url)
    end
  end

end

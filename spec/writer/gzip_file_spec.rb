require "massive_sitemap/writer/gzip_file"

describe MassiveSitemap::Writer::GzipFile do
  let(:filename)      { 'sitemap.xml' }
  let(:tmp_filename)  { "#{filename}.tmp" }
  let(:gz_filename)   { "#{filename}.gz" }

  let(:writer) { MassiveSitemap::Writer::GzipFile.new.tap { |w| w.init! } }

  after do
    writer.each { |path| FileUtils.rm(path.first) rescue nil }
  end

  it 'creates gzip file' do
    expect do
      writer.close!
    end.to change { File.exists?(gz_filename) }.to(true)
  end

  context "with root" do
    let(:root) { "sitemap"}

    let(:writer) { MassiveSitemap::Writer::GzipFile.new(:root => root).tap { |w| w.init! } }

    after do
      FileUtils.rm_rf(root) rescue nil
    end

    it 'creates gzip file in document root' do
      expect do
        writer.close!
      end.to change { File.exists?("sitemap/#{gz_filename}") }.to(true)
    end
  end
end

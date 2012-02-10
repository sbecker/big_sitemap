require "massive_sitemap/writer/gzip_file"

describe MassiveSitemap::Writer::GzipFile do
  let(:filename) { 'sitemap.xml' }
  let(:tmp_filename) { "#{filename}.tmp" }
  let(:gz_filename) { "#{filename}.gz" }
  let(:writer) { MassiveSitemap::Writer::GzipFile.new.tap { |w| w.init! } }

  after do
    FileUtils.rm(filename) rescue nil
    FileUtils.rm(tmp_filename) rescue nil
    FileUtils.rm(gz_filename) rescue nil
  end

  it 'creates gzip file' do
    expect do
      writer.close!
    end.to change { File.exists?(gz_filename) }.from(false).to(true)
  end
end

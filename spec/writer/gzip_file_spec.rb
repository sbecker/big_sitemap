require "massive_sitemap/writer/gzip_file"

describe MassiveSitemap::Writer::GzipFile do
  let(:file_name) { 'test.txt' }
  let(:tmp_file_name) { "#{file_name}.tmp" }
  let(:gz_file_name) { "#{file_name}.gz" }
  let(:writer) { MassiveSitemap::Writer::GzipFile.new(file_name).tap { |w| w.init! } }

  after do
    FileUtils.rm(file_name) rescue nil
    FileUtils.rm(tmp_file_name) rescue nil
    FileUtils.rm(gz_file_name) rescue nil
  end

  it 'creates gzip file' do
    expect do
      writer.close!
    end.to change { File.exists?(gz_file_name) }.from(false).to(true)
  end
end

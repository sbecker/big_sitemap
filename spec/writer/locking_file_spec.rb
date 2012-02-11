require "massive_sitemap/writer/locking_file"

describe MassiveSitemap::Writer::LockingFile do
  let(:filename) { 'sitemap.xml' }
  let(:tmp_filename) { "#{filename}.tmp" }
  let(:lock_file) {  MassiveSitemap::Writer::LockingFile::LOCK_FILE }
  let(:writer) { MassiveSitemap::Writer::LockingFile.new.tap { |w| w.init! } }

  after do
    FileUtils.rm(filename) rescue nil
    FileUtils.rm(tmp_filename) rescue nil
    FileUtils.rm(lock_file) rescue nil
  end

  it 'creates lockfile' do
    expect do
      writer
    end.to change { File.exists?(lock_file) }.to(true)
  end

  it 'deletes lockfile' do
    writer
    expect do
      writer.close!
    end.to change { File.exists?(lock_file) }.to(false)
  end

  it 'fails if lockfile exists' do
    File.open(lock_file, 'w') {}
    expect do
      writer
    end.to raise_error
  end
end

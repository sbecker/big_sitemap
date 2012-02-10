require "massive_sitemap/writer/locking_file"

describe MassiveSitemap::Writer::LockingFile do
  let(:file_name) { 'test.txt' }
  let(:lock_file) {  MassiveSitemap::Writer::LockingFile::LOCK_FILE }
  let(:writer) { MassiveSitemap::Writer::LockingFile.new(file_name).tap { |w| w.init! } }

  after do
    FileUtils.rm(file_name) rescue nil
    FileUtils.rm(lock_file) rescue nil
  end

  it 'creates lockfile' do
    expect do
      writer
    end.to change { File.exists?(lock_file) }.from(false).to(true)
  end

  it 'deletes lockfile' do
    writer
    expect do
      writer.close!
    end.to change { File.exists?(lock_file) }.from(true).to(false)
  end

  it 'fails if lockfile exists' do
    expect do
      File.open(lock_file, 'w', File::EXCL)
      writer
    end.to raise_error
  end
end

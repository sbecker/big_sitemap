require "spec_helper"

describe BigSitemap::FileWriter do
  let(:file_name) { 'test.txt' }
  let(:file_name2) { 'test-1.txt' }
  let(:writer) { BigSitemap::FileWriter.new(file_name).tap { |w| w.init! } }

  after do
    FileUtils.rm(file_name) rescue nil
    FileUtils.rm(file_name2) rescue nil
  end

  it 'wrong template' do
    file_name = 'test'
    BigSitemap::FileWriter.new(file_name)
  end

  it 'create file' do
    writer.close!
    File.exists?(file_name).should be_true
  end

  it 'create second file on rotation' do
    writer.close!
    File.exists?(file_name).should be_true
    writer.init!
    writer.close!
    File.exists?(file_name2).should be_true
  end

  it 'write into file' do
    writer.print 'test'
    writer.close!
    `cat '#{file_name}'`.should == "test"
  end

  it 'write into second file' do
    writer.print 'test'
    writer.init!
    writer.print 'test2'
    writer.close!
    `cat '#{file_name2}'`.should == "test2"
  end
end

describe BigSitemap::LockingFileWriter do
  let(:file_name) { 'test.txt' }
  let(:lock_file) { BigSitemap::LockingFileWriter::LOCK_FILE }
  let(:writer) { BigSitemap::LockingFileWriter.new(file_name).tap { |w| w.init! } }

  after do
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

require "spec_helper"

describe BigSitemap::FileWriter do
  let(:file_name) { 'test.txt' }
  let(:file_name2) { 'test-1.txt' }
  let(:file) { BigSitemap::FileWriter.new(file_name) }

  after do
    FileUtils.rm(file_name) rescue nil
    FileUtils.rm(file_name2) rescue nil
  end

  it 'wrong template' do
    file_name = 'test'
    BigSitemap::FileWriter.new(file_name)
  end

  it 'create file' do
    file.close
    File.exists?(file_name).should be_true
  end

  it 'create second file on rotation' do
    file.rotate
    file.close
    File.exists?(file_name).should be_true
    File.exists?(file_name2).should be_true
  end

  it 'write into file' do
    file.print 'test'
    file.close
    `cat '#{file_name}'`.should == "test"
  end

  it 'write into second file' do
    file.print 'test'
    file.rotate
    file.print 'test2'
    file.close
    `cat '#{file_name2}'`.should == "test2"
  end
end

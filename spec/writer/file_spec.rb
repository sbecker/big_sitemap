require "spec_helper"

require "massive_sitemap/writer/file"

describe MassiveSitemap::Writer::File do
  let(:filename) { 'sitemap.xml' }
  let(:filename2) { 'sitemap-1.xml' }
  let(:writer) {  MassiveSitemap::Writer::File.new.tap { |w| w.init! } }

  after do
    FileUtils.rm(filename) rescue nil
    FileUtils.rm(filename2) rescue nil
  end

  describe "document_full" do
    let(:document_full) { "test/test2" }

    after do
      FileUtils.rm_rf(document_full) rescue nil
    end

    it 'mkdir_p folder' do
      expect do
        MassiveSitemap::Writer::File.new(:document_full => document_full).tap do |w|
          w.init!
          w.close!
        end
      end.to change { File.exists?(document_full) }.to(true)
    end

    it 'appends document_full' do
      expect do
        MassiveSitemap::Writer::File.new(:document_full => document_full).tap do |w|
          w.init!
          w.close!
        end
      end.to change { File.exists?("#{document_full}/#{filename}") }.to(true)
    end

    it 'appends document_full' do
      expect do
        MassiveSitemap::Writer::File.new(:document_full => "#{document_full}/").tap do |w|
          w.init!
          w.close!
        end
      end.to change { File.exists?("#{document_full}/#{filename}") }.to(true)
    end
  end

  it 'create file' do
    expect do
      writer.close!
    end.to change { File.exists?(filename) }.to(true)
  end

  it 'create second file on rotation' do
    expect do
      expect do
        writer.close!
      end.to change { File.exists?(filename) }.to(true)
      writer.init!(:filename => filename2)
      writer.close!
    end.to change { File.exists?(filename2) }.to(true)
  end

  it 'write into file' do
    writer.print 'test'
    writer.close!
    `cat '#{filename}'`.should == "test"
  end

  it 'init new file closes current' do
    writer.print 'test'
    writer.init!(:filename => filename2)
    `cat '#{filename}'`.should == "test"
  end

  it 'write into second file' do
    writer.print 'test'
    writer.init!(:filename => filename2)
    writer.print 'test2'
    writer.close!
    `cat '#{filename2}'`.should == "test2"
  end

  context "opening write file" do
    before do
      File.open(filename, 'w') {}
    end

    after do
      FileUtils.rm(filename) rescue nil
    end

    it 'raises when file exits' do
      writer = MassiveSitemap::Writer::File.new
      expect do
        writer.init!
      end.to raise_error(MassiveSitemap::Writer::File::FileExistsException)
    end

    it 'raises when file exits' do
      writer = MassiveSitemap::Writer::File.new(:force_overwrite => true)
      expect do
        writer.init!
      end.to_not raise_error(MassiveSitemap::Writer::File::FileExistsException)
    end
  end
end

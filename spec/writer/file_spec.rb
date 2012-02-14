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

  describe "root" do
    let(:root) { "test/test2" }

    after do
      FileUtils.rm_rf(File.dirname(root)) rescue nil
    end

    it 'mkdir_p folder' do
      expect do
        MassiveSitemap::Writer::File.new(:root => root).tap do |w|
          w.init!
          w.close!
        end
      end.to change { File.exists?(root) }.to(true)
    end

    it 'appends root' do
      expect do
        MassiveSitemap::Writer::File.new(:root => root).tap do |w|
          w.init!
          w.close!
        end
      end.to change { File.exists?("#{root}/#{filename}") }.to(true)
    end

    it 'appends root' do
      expect do
        MassiveSitemap::Writer::File.new(:root => "#{root}/").tap do |w|
          w.init!
          w.close!
        end
      end.to change { File.exists?("#{root}/#{filename}") }.to(true)
    end
  end

  it 'creates file' do
    expect do
      writer.close!
    end.to change { File.exists?(filename) }.to(true)
  end

  it 'creates second file on rotation' do
    expect do
      expect do
        writer.close!
      end.to change { File.exists?(filename) }.to(true)
      writer.init!(:filename => filename2)
      writer.close!
    end.to change { File.exists?(filename2) }.to(true)
  end

  it 'writes into file' do
    writer.print 'test'
    writer.close!
    `cat '#{filename}'`.should == "test"
  end

  it 'inits new file does not closes current' do
    expect do
      writer.print 'test'
      writer.init!(:filename => filename2)
    end.to_not change { File.exists?(filename) }
  end

  it 'writes into second file' do
    writer.print 'test'
    writer.init!(:filename => filename2)
    writer.print 'test2'
    writer.close!
    `cat '#{filename2}'`.should == "test2"
  end

  context "file exists" do
    before do
      File.open(filename, 'w') {}
    end

    it 'raises when file exits' do
      writer = MassiveSitemap::Writer::File.new
      expect do
        writer.init!
      end.to raise_error(MassiveSitemap::Writer::File::FileExistsException)
    end

    it "dosn't raise when overwrite set" do
      writer = MassiveSitemap::Writer::File.new(:force_overwrite => true)
      expect do
        writer.init!
        writer.close!
      end.to_not raise_error(MassiveSitemap::Writer::File::FileExistsException)
    end
  end
end

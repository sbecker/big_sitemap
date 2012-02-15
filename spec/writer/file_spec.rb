require "spec_helper"
require "time"

require "massive_sitemap/writer/file"

describe MassiveSitemap::Writer::File do
  let(:filename) { 'sitemap.xml' }
  let(:filename2) { 'sitemap-1.xml' }
  let(:writer) {  MassiveSitemap::Writer::File.new.tap { |w| w.init! } }

  after do
    FileUtils.rm(filename) rescue nil
    FileUtils.rm(filename2) rescue nil
  end

  describe "set" do
    it "updates filename" do
      writer.set(:filename => "test").send(:filename).should == "./test"
    end
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

  describe "#with_rotation" do
    let(:writer) {  MassiveSitemap::Writer::File.new }

    context "keeps filename" do
      it "rotation is zero" do
        writer.send(:with_rotation, "sitemap.xml").should == "sitemap-1.xml"
      end

      it "rotation is zero" do
        writer.send(:with_rotation, "sitemap2.xml").should == "sitemap2-1.xml"
      end

      it "rotation is zero" do
        writer.send(:with_rotation, "sitemap-1.xml").should == "sitemap-2.xml"
      end

      it "rotation is zero" do
        writer.send(:with_rotation, "sitemap-1-1.xml").should == "sitemap-1-2.xml"
      end

      it "rotation is nil" do
        writer.send(:with_rotation, "sitemap-user.xml").should == "sitemap-user-1.xml"
      end
    end
  end

  describe "#split_filename" do
    let(:writer) {  MassiveSitemap::Writer::File.new }

    FILENAMES = {
      nil                     => ["", nil, nil],
      ".xml"                  => ["", nil, ".xml"],
      ".xml.gz"               => ["", nil, ".xml.gz"],
      "sitemap"               => ["sitemap", nil, nil],
      "sitemap.xml"           => ["sitemap", nil, ".xml"],
      "sitemap.xml.gz"        => ["sitemap", nil, ".xml.gz"],
      "-1.xml"                => ["", "1", ".xml"],
      "-1.xml.gz"             => ["", "1", ".xml.gz"],
      "sitemap-1"             => ["sitemap", "1", nil],
      "sitemap-1.xml"         => ["sitemap", "1", ".xml"],
      "sitemap-1.xml.gz"      => ["sitemap", "1", ".xml.gz"],
      "-user-1.xml"           => ["-user", "1", ".xml"],
      "-user-1.xml.gz"        => ["-user", "1", ".xml.gz"],
      "sitemap-user-1"        => ["sitemap-user", "1", nil],
      "sitemap-user-1.xml"    => ["sitemap-user", "1", ".xml"],
      "sitemap-user-1.xml.gz" => ["sitemap-user", "1", ".xml.gz"],
      "sitemap1"              => ["sitemap1", nil, nil],
      "sitemap1.xml"          => ["sitemap1", nil, ".xml"],
      "sitemap1.xml.gz"       => ["sitemap1", nil, ".xml.gz"],
    }

    FILENAMES.each do |filename, expected|
      it "splits filename #{filename} into #{expected.join(' ')}" do
        writer.send(:split_filename, filename).should == expected
      end
    end
  end

  describe "upper_stream_ids" do
    let(:writer) {  MassiveSitemap::Writer::File.new }

    it { writer.send(:upper_stream_ids, %w(sitemap-1.xml)).should == %w(sitemap-1.xml) }
    it { writer.send(:upper_stream_ids, %w(sitemap-2.xml sitemap-1.xml)).should == %w(sitemap-2.xml) }
    it { writer.send(:upper_stream_ids, %w(sitemap.xml sitemap_user-1.xml)).should == %w(sitemap.xml sitemap_user-1.xml) }
  end

  describe "chaos_monkey_stream_ids" do
    let(:writer) {  MassiveSitemap::Writer::File.new }

    context "one file" do
      it { writer.send(:chaos_monkey_stream_ids, %w(sitemap-1.xml), 0).should == [] }
      it { writer.send(:chaos_monkey_stream_ids, %w(sitemap-1.xml), 1).should == %w(sitemap-1.xml) }

      it "keeps file for 2 days" do
        Time.stub!(:now).and_return(Time.parse("1-1-2012").utc)
        writer.send(:chaos_monkey_stream_ids, %w(sitemap-1.xml), 2).should == []
      end

      it "deletes file on snd day" do
        Time.stub!(:now).and_return(Time.parse("2-1-2012").utc)
        writer.send(:chaos_monkey_stream_ids, %w(sitemap-1.xml), 2).should == %w(sitemap-1.xml)
      end
    end

    context "many files" do
      it "keeps file for 2 days" do
        Time.stub!(:now).and_return(Time.parse("1-1-2012").utc)
        writer.send(:chaos_monkey_stream_ids, %w(sitemap-1.xml sitemap-2.xml sitemap-3.xml), 2).should == %w(sitemap-2.xml)
      end

      it "deletes file on 2nd day" do
        Time.stub!(:now).and_return(Time.parse("2-1-2012").utc)
        writer.send(:chaos_monkey_stream_ids, %w(sitemap-1.xml sitemap-2.xml sitemap-3.xml), 2).should == %w(sitemap-1.xml sitemap-3.xml)
      end

      it "deletes file on 3rd day" do
        Time.stub!(:now).and_return(Time.parse("3-1-2012").utc)
        writer.send(:chaos_monkey_stream_ids, %w(sitemap-1.xml sitemap-2.xml sitemap-3.xml), 2).should == %w(sitemap-2.xml)
      end
    end
  end

end

require "spec_helper"

require "massive_sitemap/builder/rotating"
require "massive_sitemap/writer/string"

describe MassiveSitemap::Builder::Rotating do
  let(:header) { %Q(<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">) }
  let(:writer) { MassiveSitemap::Writer::String.new }
  let(:builder) { MassiveSitemap::Builder::Rotating.new(writer) }

  it 'raises error when max_per_sitemap > MAX_URLS' do
    expect do
      MassiveSitemap::Builder::Rotating.new(writer, :max_per_sitemap => MassiveSitemap::Builder::Rotating::NUM_URLS.max + 1)
    end.to raise_error(ArgumentError)
  end

  it 'generates one url' do
    MassiveSitemap::Builder::Rotating.new(writer) do
      add_url! 'test'
    end
    writer.string.should == %Q(#{header}\n  <url>\n    <loc>test</loc>\n  </url>\n</urlset>)
  end

  it 'generates two url' do
    writer.should_receive(:init!).twice
    writer.should_receive(:close!).twice
    MassiveSitemap::Builder::Rotating.new(writer, :max_per_sitemap => 1) do
      add_url! 'test'
      add_url! 'test2'
    end
    writer.string.should == %Q(#{header}\n  <url>\n    <loc>test</loc>\n  </url>\n</urlset>#{header}\n  <url>\n    <loc>test2</loc>\n  </url>\n</urlset>)
  end

  context "with file" do
    let(:filename) { 'sitemap.xml' }
    let(:filename2) { 'sitemap-1.xml' }
    let(:writer) { MassiveSitemap::Writer::File.new }

    after do
      FileUtils.rm(filename) rescue nil
      FileUtils.rm(filename2) rescue nil
    end

    it 'generates two url' do
      expect do
        expect do
          MassiveSitemap::Builder::Rotating.new(writer, :max_per_sitemap => 1) do
            add 'test'
            add 'test2'
          end
        end.to change { File.exists?(filename) }.to(true)
      end.to change { File.exists?(filename2) }.to(true)
    end

    it 'generates two url when file exists' do
      File.open(filename, 'w') {}
      expect do
        expect do
          MassiveSitemap::Builder::Rotating.new(writer, :max_per_sitemap => 1) do
            begin
              add 'test'
            rescue MassiveSitemap::Writer::File::FileExistsException => e
            end
            add 'test2'
          end
        end.to_not change { File.exists?(filename) }.to(true)
      end.to change { File.exists?(filename2) }.to(true)
    end
  end

  describe "#filename_with_rotation" do
    context "keeps filename" do
      it "rotation is zero" do
        builder.send(:filename_with_rotation, "sitemap.xml").should == "sitemap.xml"
      end

      it "rotation is zero" do
        builder.send(:filename_with_rotation, "sitemap2.xml").should == "sitemap2.xml"
      end

      it "rotation is zero" do
        builder.send(:filename_with_rotation, "sitemap.xml", nil).should == "sitemap.xml"
      end

      it "rotation is nil" do
        builder.send(:filename_with_rotation, "sitemap.xml", 0).should == "sitemap.xml"
      end
    end

    context "rotation is 1" do
      it "add prefix" do
        builder.send(:filename_with_rotation, "sitemap.xml", 1).should == "sitemap-1.xml"
      end

      it "rotation is zero" do
        builder.send(:filename_with_rotation, "sitemap-1.xml", 1).should == "sitemap-1.xml"
      end

      it "rotation is zero" do
        builder.send(:filename_with_rotation, "sitemap-user.xml", 1).should == "sitemap-user-1.xml"
      end
    end
  end

  describe "#split_filename" do
    FILENAMES = {
      nil                     => ["", nil, nil],
      ".xml"                  => ["", nil, ".xml"],
      ".xml.gz"               => ["", nil, ".xml.gz"],
      "sitemap"               => ["sitemap", nil, nil],
      "sitemap.xml"           => ["sitemap", nil, ".xml"],
      "sitemap.xml.gz"        => ["sitemap", nil, ".xml.gz"],
      "-1.xml"                => ["", "-1", ".xml"],
      "-1.xml.gz"             => ["", "-1", ".xml.gz"],
      "sitemap-1"             => ["sitemap", "-1", nil],
      "sitemap-1.xml"         => ["sitemap", "-1", ".xml"],
      "sitemap-1.xml.gz"      => ["sitemap", "-1", ".xml.gz"],
      "-user-1.xml"           => ["-user", "-1", ".xml"],
      "-user-1.xml.gz"        => ["-user", "-1", ".xml.gz"],
      "sitemap-user-1"        => ["sitemap-user", "-1", nil],
      "sitemap-user-1.xml"    => ["sitemap-user", "-1", ".xml"],
      "sitemap-user-1.xml.gz" => ["sitemap-user", "-1", ".xml.gz"],
      "sitemap1"              => ["sitemap1", nil, nil],
      "sitemap1.xml"          => ["sitemap1", nil, ".xml"],
      "sitemap1.xml.gz"       => ["sitemap1", nil, ".xml.gz"],
    }

    FILENAMES.each do |filename, expected|
      it "splits filename #{filename} into #{expected.join(' ')}" do
        builder.send(:split_filename, filename).should == expected
      end
    end
  end

end

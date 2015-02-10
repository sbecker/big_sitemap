require "spec_helper"

require "massive_sitemap/writer/base"

describe MassiveSitemap::Writer::Base do
   let(:writer) { MassiveSitemap::Writer::Base.new }

   describe "set" do
     it "returns itself" do
       writer.set(:filename => "test").should == writer
     end
   end
end

# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "massive_sitemap/version"

Gem::Specification.new do |s|
  s.name        = "massive_sitemap"
  s.version     = MassiveSitemap::VERSION
  s.authors     = ["Tobias Bielohlawek"]
  s.email       = ["tobi@soundcloud.com"]
  s.homepage    = "http://github.com/rngtng/massive_sitemap"
  s.summary     = %q{Build painfree sitemaps for webpages with millions of pages}
  s.description = %q{MassiveSitemap - allows you to generate. Differential updates keeps generation time short and reduces load on DB. It's inspired and party based on BigSitemaps}

  s.rubyforge_project = "massive_sitemap"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  %w(rake rspec).each do |gem|
    s.add_development_dependency *gem.split(' ')
  end
end

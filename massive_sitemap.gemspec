# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "massive_sitemap"
  s.version     = File.read("VERSION").to_s.strip
  s.authors     = ["Tobias Bielohlawek"]
  s.email       = ["tobi@soundcloud.com"]
  s.homepage    = "http://github.com/rngtng/massive_sitemap"
  s.summary     = %q{Build painfree sitemaps for websites with millions of pages}
  s.description = %q{MassiveSitemap - build huge sitemaps painfree. Differential updates keeps generation time short and reduces load on DB. It's heavealy inspired by BigSitemaps and offers compatiable API}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  %w(rake rspec).each do |gem|
    s.add_development_dependency *gem.split(' ')
  end
end

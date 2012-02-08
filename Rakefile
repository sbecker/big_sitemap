require 'bundler/gem_tasks'

require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test' << Rake.original_dir
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
end

task :default => :spec

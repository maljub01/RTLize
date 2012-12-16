#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Rtlize'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end




Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end


task :default => :test

desc "Build gem"
task :build do
  system "gem build rtlize.gemspec"
  FileUtils.mkdir_p "pkg"
  FileUtils.mv "rtlize-#{Rtlize::VERSION}.gem", "pkg"
end

task :tag do
  system "git tag v#{Rtlize::VERSION}"
  system "git push origin v#{Rtlize::VERSION}"
end

task :release => :build do
  system "cd pkg && gem push rtlize-#{Rtlize::VERSION}"
end

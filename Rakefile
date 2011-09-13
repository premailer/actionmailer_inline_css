#!/usr/bin/env rake
$:.unshift File.expand_path('../lib', __FILE__)

require 'rake'
require 'rake/testtask'
require 'rake/packagetask'
require 'rubygems/package_task'

spec = eval(File.read('actionmailer_inline_css.gemspec'))

Gem::PackageTask.new(spec) do |p|
  p.gem_spec = spec
end

desc "Release to gemcutter"
task :release => :package do
  require 'rake/gemcutter'
  Rake::Gemcutter::Tasks.new(spec).define
  Rake::Task['gem:push'].invoke
end

desc "Default Task"
task :default => [ :test ]

# Run the unit tests
Rake::TestTask.new { |t|
  t.libs << "test"
  t.pattern = 'test/**/*_test.rb'
  t.warning = true
}


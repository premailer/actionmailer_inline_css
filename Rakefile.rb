$:.unshift File.expand_path('../lib', __FILE__)

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'

def gemspec
 @gemspec ||= begin
   file = File.expand_path('../actionmailer_inline_css.gemspec', __FILE__)
   eval(File.read(file), binding, file)
 end
end

Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.need_tar = true
end


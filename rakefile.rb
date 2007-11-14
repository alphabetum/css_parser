require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'fileutils'
require 'lib/css_parser'

include CssParser

desc 'Default: parse a URL.'
task :default => [:parse]

desc 'Parse a URL and write out the output.'
task :parse do
  url = ENV['url']
  
  if !url or url.empty?
    puts 'Usage: rake parse url=http://example.com/'
    exit
  end

  premailer = Premailer.new(url, :warn_level => Premailer::Warnings::SAFE)
  fout = File.open('out.html', "w")
  fout.puts premailer.to_inline_css
  fout.close

  puts "Succesfully parsed '#{url}' into 'out.html'"
  puts premailer.warnings.length.to_s + ' CSS warnings were found'
end

desc 'Run the unit tests.'
Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.libs << 'lib/test'
  t.test_files = FileList['test/test*.rb'].exclude('test_helper.rb')
  t.verbose = false
end


desc 'Generate documentation.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'CSS Parser'
  rdoc.options << '--all' << '--inline-source' << '--line-numbers'
  rdoc.rdoc_files.include('CHANGELOG')
  rdoc.rdoc_files.include('LICENSE')
  rdoc.rdoc_files.include('lib/*.rb')
  rdoc.rdoc_files.include('lib/css_parser/*.rb')
end

spec = Gem::Specification.new do |s| 
  s.name = "css_parser"
  s.version = "0.9.0"
  s.author = "Alex Dunae"
  s.homepage = "http://code.dunae.ca/css_parser"
  s.platform = Gem::Platform::RUBY
  s.summary = "Set of classes for parsing CSS."
  s.files = FileList["{lib}/**/*"].to_a
  s.test_files = Dir.glob('test/test_*.rb') 
  s.has_rdoc = true
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE"]
  s.rdoc_options << '--all' << '--inline-source' << '--line-numbers'
end

desc 'Build the W3C Validators gem.'
Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_zip = true
  pkg.need_tar = true 
end 
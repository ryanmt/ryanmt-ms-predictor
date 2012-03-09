# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "ryanmt-ms-predictor"
  gem.homepage = "http://github.com/ryanmt/ryanmt-ms-predictor"
  gem.license = "MIT"
  gem.summary = %Q{My in-silico analysis toolkit for generating theoretical data representative of a set of proteins as contained in a fasta file.}
  gem.description = %Q{This gem provides in-silico generation of data files representative of a theoretical analysis of proteins as provided in a source fasta file.  This is essentially the toolkit required to do comparative studies between real data and database entries in identifying peptides from mass spectra ie MASCOT, SEQUEST, OMSSA, ... }
  gem.email = "ryanmt@byu.net"
  gem.authors = ["Ryan Taylor"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end


task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ryanmt-ms-predictor #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

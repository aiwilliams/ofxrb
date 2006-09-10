require 'rake'
require 'rake/testtask'
require 'getoptlong'

task :default => ["gem"]

desc "Execute racc to generate parsers"
file "lib/ofx_102.rb" => ["lib/ofx_102.y"] do
  # add -g to generate testing support, and enable yydebug in ofx_102.y
  Dir.chdir('lib') { sh "racc -o ofx_102.rb ofx_102.y" }
end

desc "Create a gem"
task :gem => ["lib/ofx_102.rb", :test_units] do
  require 'rubygems'

  spec = Gem::Specification.new do |s|
    s.name = 'ofxrb'
    s.version = "0.0.1"
    s.platform = Gem::Platform::RUBY
    s.add_dependency('activesupport', '>= 1.3.1')
    s.summary = "ofxrb is a pure-Ruby OFX (Open Financial Exchange) library"
    s.required_ruby_version = '>= 1.8.1' # for Racc Runtime Module
    s.files = Dir.glob("lib/**/*").delete_if {|item| item.include?(".svn") or item.include?("ofx_102.y")}
    s.require_path = 'lib'
    s.autorequire = 'ofxrb'
    s.author = "Adam Williams, Austin Taylor"
    s.email = "adam@thewilliams.ws"
    s.rubyforge_project = "ofxrb"
    s.homepage = "http://ofxrb.rubyforge.org"
  end
  
  Gem.manage_gems
  Gem::Builder.new(spec).build
end

desc "Run tests"
Rake::TestTask.new(:test_units) do |t|
  t.pattern = 'test/unit/*_test.rb'
  t.verbose = true
  t.warning = true
end
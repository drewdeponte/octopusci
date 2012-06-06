$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib')

require 'octopusci/version'

Gem::Specification.new do |s|
  s.name        = 'octopusci'
  s.platform    = Gem::Platform::RUBY
  s.version     = Octopusci::VERSION
  s.summary     = %q{A continuous integration application using Sinatra.}
  s.description = %q{A multi-branch Continuous Integration server that integrates with GitHub}
  s.authors     = ['Andrew De Ponte', 'Aldo Sarmiento']
  s.email       = ['cyphactor@gmail.com', 'sarmiena@gmail.com']
  s.homepage    = 'https://github.com/cyphactor/octopusci'
  
  s.files       = %w( README.markdown LICENSE config.ru )
  s.files       += Dir.glob("lib/**/*")
  s.files       += Dir.glob("bin/**/*")
  s.files       += Dir.glob("man/**/*")
  s.files       += Dir.glob("spec/**/*")
  s.files       += Dir.glob("extra/**/*")
  s.executables = [ "octopusci-tentacles", "octopusci-skel", "octopusci-reset-redis", "octopusci-reset-stage-locker", "octopusci-post-build-request" ]
  
  s.add_dependency 'sinatra'
  s.add_dependency 'json'
  s.add_dependency 'resque'
  s.add_dependency 'actionmailer'
  s.add_dependency 'multi_json'
  s.add_dependency 'time-ago-in-words'
  s.add_dependency 'ansi2html'
  s.add_dependency 'trollop'
  
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'ruby_gntp'
  s.add_development_dependency 'pry'
end
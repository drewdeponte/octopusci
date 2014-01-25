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
  s.licenses    = ['MIT']
  
  s.files       = %w( README.markdown LICENSE config.ru )
  s.files       += Dir.glob("lib/**/*")
  s.files       += Dir.glob("bin/**/*")
  s.files       += Dir.glob("man/**/*")
  s.files       += Dir.glob("spec/**/*")
  s.files       += Dir.glob("extra/**/*")
  s.executables = [ "octopusci-tentacles", "octopusci-skel", "octopusci-reset-redis", "octopusci-reset-stage-locker", "octopusci-post-build-request" ]
  
  s.add_dependency 'sinatra', '~> 1.4'
  s.add_dependency 'json', '~> 1.8'
  s.add_dependency 'resque', '~> 1.25'
  s.add_dependency 'actionmailer', '~> 4.0'
  s.add_dependency 'multi_json', '~> 1.8'
  s.add_dependency 'time_ago_in_words', '~> 0.1'
  s.add_dependency 'ansi2html', '~> 5.3'
  s.add_dependency 'trollop', '~> 2.0'
  
  s.add_development_dependency 'rake', '~> 10.1'
  s.add_development_dependency 'rspec', '~> 2.14'
  s.add_development_dependency 'rack-test', '~> 0.6'
end

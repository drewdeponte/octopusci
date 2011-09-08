Gem::Specification.new do |s|
  s.name        = 'octopusci'
  s.platform    = Gem::Platform::RUBY
  s.version     = '0.0.1'
  s.date        = '2011-09-07'
  s.summary     = 'A continuous integration application using Sinatra.'
  s.description = 'Automates rspec and cucumber testing when pull requests are made to a github repository.'
  s.authors     = ['Drew De Ponte']
  s.email       = ['cyphactor@gmail.com']
  s.homepage    = 'https://github.com/cyphactor/octopusci'
  
  s.files       = %w( README Rakefile LICENSE )
  s.files       += Dir.glob("lib/**/*")
  s.files       += Dir.glob("bin/**/*")
  s.files       += Dir.glob("man/**/*")
  s.files       += Dir.glob("spec/**/*")
  
  s.add_dependency 'sinatra'
  s.add_dependency 'json'
  s.add_dependency 'resque'
  s.add_dependency 'grit'
  s.add_dependency 'actionmailer'
end
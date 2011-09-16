$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'octopusci/server'
require 'rack/test'

Octopusci::Server.set :environment, :test

def app
  Octopusci::Server
end

include Rack::Test::Methods

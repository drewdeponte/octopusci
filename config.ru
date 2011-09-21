$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib')
require 'resque/server'
require 'octopusci/server'

run Rack::URLMap.new("/" => Octopusci::Server.new, "/resque" => Resque::Server.new)

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib')
require 'resque/server'
require 'octopusci/server'

# Set the AUTH env variable to your basic auth password to protect Resque.
Resque::Server.use Rack::Auth::Basic do |username, password|
  (username == Octopusci::Config['http_basic']['username']) && (password == Octopusci::Config['http_basic']['password'])
end

run Rack::URLMap.new("/" => Octopusci::Server.new, "/resque" => Resque::Server.new)

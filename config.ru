$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib')
require 'octopusci/server'
Octopusci::WorkerLauncher.launch
run Octopusci::Server
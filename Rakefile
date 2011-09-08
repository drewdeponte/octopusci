$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib')
require 'octopusci'

Octopusci.configure("/etc/octopusci.yml")

require File.expand_path('../my_test_job.rb', __FILE__)

require 'resque/tasks'
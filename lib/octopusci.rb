require 'octopusci/version'
require 'octopusci/notifier'
require 'octopusci/queue'
require 'octopusci/job'
require 'octopusci/config'

module Octopusci
  def self.greet
    return "Hello RSpec!"
  end
end
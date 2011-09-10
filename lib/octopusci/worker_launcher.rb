require 'resque'
require 'octopusci/config'

require File.expand_path('../../../my_test_job.rb', __FILE__)

module Octopusci
  module WorkerLauncher
    def self.launch
      threads = []
      
      Octopusci.configure("/etc/octopusci.yml")
      
      if Octopusci::CONFIG['stages'] == nil
        raise "You have defined stages as an option but have no items in it."
      end
      
      Octopusci::CONFIG['stages'].size.times do
        # threads << Thread.new do
        cur_pid = Process.fork do
          queues = ['commit']
          worker = Resque::Worker.new(*queues)
          worker.log "Starting worker #{worker}"
          worker.work(5)
        end
        Process.detach(cur_pid)
      end
      # threads.each { |thread| thread.join }
    end
  end
end

require 'resque'
require 'octopusci/config'

module Octopusci
  module WorkerLauncher
    def self.launch
      Octopusci::CONFIG['stages'].size.times do
        cur_pid = Process.fork do
          queues = ['commit']
          worker = Resque::Worker.new(*queues)
          worker.log "Starting worker #{worker}"
          worker.work(5)
        end
        Process.waitall
      end
    end
  end
end

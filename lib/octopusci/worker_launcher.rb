require 'resque'
require 'octopusci/config'

module Octopusci
  module WorkerLauncher
    def self.cleanup_existing_workers
      exist_worker_pids = get_worker_pids()
      puts "Cleaning up any existing workers... (#{exist_worker_pids.join(',')})"
      exist_worker_pids.each do |pid|
        wait_to_finish_and_exit(pid)
      end
      del_worker_pids
      puts "Finished cleaning up workers"
    end

    def self.launch
      puts "Launching new workers..."

      # We need to disconnect the redis connection because when we fork and
      # each fork gets a copy of the same connection it is a problem and the
      # redis protocol will detect it and throw an exception. This is
      # necessary because each forked instance needs its own redis connection.
      # This only works because Resque.redis manages a singleton an instance
      # variable and if that instance variable isn't set then it reconnects
      # and returns the new connection.
      Resque.redis.quit

      worker_pids = []
      
      Octopusci::Config['stages'].size.times do
        cur_pid = Process.fork do
          queues = ['octopusci:commit']
          worker = Resque::Worker.new(*queues)
          worker.log "Starting worker #{worker}"
          worker.work(5)
        end
        
        worker_pids << cur_pid
        
        Process.detach(cur_pid)
        
        puts "Launched worker with pid (#{cur_pid})"
      end
      
      worker_pids.each do |pid|
        push_worker_pid(pid)
      end
      
      puts "Finished launching workers"
    end
    
    def self.kill(signal_str, pid)
      begin
        Process.kill(signal_str, pid.to_i)
        puts "Sent '#{signal_str}' signal to worker with pid (#{pid})"
      rescue Errno::ESRCH => e
        puts "Failed to send '#{signal_str}' to worker with pid (#{pid}) - #{e.to_s}"
      end
    end
     
    def self.wait_to_finish_and_exit(pid)
      kill("QUIT", pid)
    end
    
    def self.immediately_kill_child_and_exit(pid)
      kill("TERM", pid)
    end
    
    def self.immediately_kill_child(pid)
      kill("USR1", pid)
    end
    
    def self.do_not_process_new_jobs(pid)
      kill("USR2", pid)
    end
    
    def self.start_to_process_new_jobs_again(pid)
      kill("CONT", pid)
    end
    
    def self.push_worker_pid(pid)
      Resque.redis.rpush(pids_list_key, pid)
    end
    
    def self.get_worker_pids
      len = Resque.redis.llen(pids_list_key())
      if len > 0
        return Resque.redis.lrange(pids_list_key(), 0, len-1)
      else
        return []
      end
    end
    
    def self.del_worker_pids
      Resque.redis.del(pids_list_key())
    end
    
    def self.pids_list_key
      "octopusci:workerpids"
    end
  end
end

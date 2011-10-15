require 'resque'

module Octopusci
  module StageLocker
    def self.load(stages)
      clear
      stages.each { |s| push(s) }
    end
    
    def self.clear
      Resque.redis.del('octopusci:stagelocker')
    end
    
    def self.pop
      Resque.redis.lpop('octopusci:stagelocker')
    end
    
    def self.rem(v)
      Resque.redis.lrem('octopusci:stagelocker', 1, v)
    end
    
    def self.push(v)
      Resque.redis.rpush('octopusci:stagelocker', v)
    end
    
    def self.stages
      Octopusci::Config['stages']
    end
    
    def self.pool
      len = Resque.size('octopusci:stagelocker')
      Resque.peek('octopusci:stagelocker', 0, len)
    end
  end
end
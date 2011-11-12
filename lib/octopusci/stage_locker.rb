require 'resque'

module Octopusci
  module StageLocker
    def self.load(stages)
      clear
      stages.each { |s| push(s) }
    end

    def self.exists?
      self.redis.exists('octopusci:stagelocker')
    end

    def self.empty?
      !exists?
    end
    
    def self.clear
      self.redis.del('octopusci:stagelocker')
    end
    
    def self.pop
      self.redis.lpop('octopusci:stagelocker')
    end
    
    def self.rem(v)
      self.redis.lrem('octopusci:stagelocker', 1, v)
    end
    
    def self.push(v)
      self.redis.rpush('octopusci:stagelocker', v)
    end
    
    def self.stages
      Octopusci::Config['stages']
    end
    
    def self.pool
      len = self.redis.size('octopusci:stagelocker')
      self.redis.peek('octopusci:stagelocker', 0, len)
    end

    def self.redis
      Resque.redis
    end
  end
end
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
    
    def self.push(v)
      Resque.redis.rpush('octopusci:stagelocker', v)
    end
  end
end
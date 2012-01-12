require 'resque'
require 'yaml'

module Octopusci
  class RepoStore
    def self.set(repo_name, owner)
      repo_info = {
        :owner => owner,
        :name => repo_name,
        :branch => 'master'
      }

      key = "octopusci:repolist:#{repo_name}-#{owner}"
      redis.sadd("octopusci:repolist", key)
      redis.set(key, YAML.dump(repo_info))
    end

    def self.get(key)
      repo_info = redis.get(key)
      if repo_info
        return YAML.load(repo_info)
      end
      return nil
    end

    def self.get_all
      redis.smembers("octopusci:repolist")
    end

    def self.size
      redis.scard("octopusci:repolist")
    end

    def self.remove(key)
      redis.srem("octopusci:repolist", key)
    end

    def self.redis
      Resque.redis
    end
  end
end
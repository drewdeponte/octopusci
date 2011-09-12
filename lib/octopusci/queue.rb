require 'resque'

module Octopusci
  module Queue
    def self.enqueue(job_klass, proj_name, branch_name, github_payload)
      resque_opts = { "class" => job_klass, "args" => [proj_name, branch_name] }
      gh_pl_key = github_payload_key(proj_name, branch_name)

      if lismember('commit', resque_opts)
        Resque.redis.set(gh_pl_key, Resque::encode(github_payload))
        # Get the most recent job for this project and update it with the data
      else
        Resque.redis.set(gh_pl_key, Resque::encode(github_payload))
        Resque.push('commit', resque_opts)
        # Create a new job for this project with the appropriate data
      end
    end

    def self.lismember(queue, item)
      size = Resque.size(queue)
      [Resque.peek(queue, 0, size)].flatten.any? { |v|
        v == item
      }
    end
    
    def self.github_payload(project_name, branch_name)
      Resque::decode(Resque.redis.get(github_payload_key(project_name, branch_name)))
    end
    
    def self.github_payload_key(proj_name, branch_name)
      "octpusci:github_payload:#{proj_name}:#{branch_name}"
    end
  end
end
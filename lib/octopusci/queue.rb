require 'resque'

module Octopusci
  module Queue
    def self.enqueue(job_klass, proj_name, branch_name, github_payload, job_conf)
      resque_opts = { "class" => job_klass, "args" => [proj_name, branch_name] }
      gh_pl_key = github_payload_key(proj_name, branch_name)

      if lismember('octopusci:commit', resque_opts)
        self.redis.set(gh_pl_key, Resque::encode(github_payload))

        job = Octopusci::JobStore.list_repo_branch(proj_name, branch_name, 0, 1).first
        if job
          Octopusci::JobStore.set(job['id'], job.merge(Octopusci::Helpers.gh_payload_to_job_attrs(github_payload)))
        end        
      else
        # Create a new job for this project with the appropriate data
        job_id = Octopusci::JobStore.prepend(Octopusci::Helpers.gh_payload_to_job_attrs(github_payload).merge('status' => 'pending'))
        resque_opts["args"] << job_id
        resque_opts["args"] << job_conf
        self.redis.set(gh_pl_key, Resque::encode(github_payload))
        Resque.push('octopusci:commit', resque_opts)
      end
    end

    def self.lismember(queue, item)
      size = Resque.size(queue)
      [Resque.peek(queue, 0, size)].flatten.any? { |v|
        v == item
      }
    end
    
    def self.github_payload(project_name, branch_name)
      Resque::decode(self.redis.get(github_payload_key(project_name, branch_name)))
    end
    
    def self.github_payload_key(proj_name, branch_name)
      "octopusci:github_payload:#{proj_name}:#{branch_name}"
    end

    def self.redis
      Resque.redis
    end
  end
end
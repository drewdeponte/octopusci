require 'resque'

module Octopusci
  module Queue
    def self.enqueue(job_klass, proj_name, branch_name, github_payload, job_conf)
      gh_pl_key = github_payload_key(proj_name, branch_name)

      if job_pending?('octopusci:commit', proj_name, branch_name)
        self.redis.set(gh_pl_key, Resque::encode(github_payload))

        job = Octopusci::JobStore.list_repo_branch(proj_name, branch_name, 0, 1).first
        if job
          Octopusci::JobStore.set(job['id'], job.merge(Octopusci::Helpers.gh_payload_to_job_attrs(github_payload)))
        end
      else
        # Create a new job for this project with the appropriate data
        job_id = Octopusci::JobStore.prepend(Octopusci::Helpers.gh_payload_to_job_attrs(github_payload).merge('status' => 'pending'))
        self.redis.set(gh_pl_key, Resque::encode(github_payload))
        Resque.push('octopusci:commit', { "class" => job_klass, "args" => [proj_name, branch_name, job_id, job_conf] })
      end
    end

    def self.job_pending?(queue, proj_name, branch_name)
      size = Resque.size(queue)
      return [Resque.peek(queue, 0, size)].flatten.any? { |v| v["args"][0] == proj_name && v["args"][1] == branch_name }
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
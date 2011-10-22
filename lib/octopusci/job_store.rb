module Octopusci
  class JobStore
    def self.prepend(job)
      job_id = redis.incr('octopusci:job_count')
      self.set(job_id, job)
      redis.lpush("octopusci:jobs", job_id)
      return job_id
    end

    def self.set(job_id, job)
      redis.set("octopusci:jobs:#{job_id}", YAML.dump(job))
    end

    def self.get(job_id)
      job = redis.get("octopusci:jobs:#{job_id}")
      if job
        return YAML.load(job)
      end
      return nil
    end

    def self.size
      redis.llen("octopusci:jobs")
    end

    def self.list_job_ids(start_idx, num_jobs)
      len = size()
      end_idx = len - 1

      range_idx = start_idx + num_jobs
      if (end_idx - start_idx < num_jobs)
        range_idx = end_idx
      end
      redis.lrange("octopusci:jobs", 0, range_idx)
    end

    def self.list(start_idx, num_jobs)
      job_ids = list_job_ids(start_idx, num_jobs)
      job_ids.map { |id| self.get(id) }
    end

    def self.redis
      Resque.redis
    end
  end
end
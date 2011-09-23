module Octopusci
  class Job
    def self.run(github_payload, stage, job_id, job_conf)
      raise PureVirtualMethod, "The self.commit_run method needs to be defined on your Octopusci::Job."
    end

    def self.perform(project_name, branch_name, job_id, job_conf)
      ActiveRecord::Base.verify_active_connections!

      # Note: There is no logic for handling stage coming back as nil because
      # it should never happen because there are the same number of resque
      # workers as there are stages at all times.
      if Octopusci::CONFIG.has_key?('stages')
        # Get the next available stage from redis which locks it by removing it
        # from the list of available
        stage = Octopusci::StageLocker.pop
      end
      
      begin
        # Using redis to get the associated github_payload
        github_payload = Octopusci::Queue.github_payload(project_name, branch_name)
        
        job = ::Job.where("jobs.repo_name = ? && jobs.ref = ?", github_payload['repository']['name'], github_payload['ref']).order('jobs.created_at DESC').first
        if job
          job.started_at = Time.new
          job.running = true
          job.save
        end
        
        # Run the commit run and report about status and output
        # Bundler.with_clean_env {
          self.run(github_payload, stage, job_id, job_conf)
        # }
        
        if job
          job.ended_at = Time.new
          job.running = false
          job.save
        end
      ensure
        if Octopusci::CONFIG.has_key?('stages')
          # Unlock the stage by adding it back to the list of available stages
          Octopusci::StageLocker.push(stage)
        end
      end
    end    
  end
end
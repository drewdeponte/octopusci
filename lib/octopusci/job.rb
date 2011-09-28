module Octopusci
  class Job
    def self.run(job_record)
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
          job.stage = stage
          job.status = 'running'
          job.save
          
          begin
            rv = self.run(job)
            if ::Job::STATUS.keys.include?(rv)
              job.status = 0
            else
              if rv == 0
                job.status = 'successful'
              else
                job.status = 'failed'
              end
            end
          rescue => e
            File.open(job.abs_output_file_path, 'a') { |f|
              f << "\n\nException: #{e.message}\n"
              f << "-"*30
              f << "\n"
              f << e.backtrace.join("\n")
            }
            job.status = 'error'
          ensure
            job.ended_at = Time.new
            job.save
          end
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
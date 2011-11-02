module Octopusci
  class Job
    class << self
      attr_accessor :context_stack

      def inherited(subclass)
        subclass.context_stack = []
      end
    end

    def self.run(job_rec)
      raise Octopusci::PureVirtualMethod, "The self.run method needs to be defined on your Octopusci::Job based class."
    end

    def self.context(desc_str)
      context_stack.push(desc_str)
      begin
        yield
      rescue Octopusci::JobRunFailed => e
        # setup notification and send notification
        raise JobHalted.new("JobRunFailed: #{e.message}")
      ensure
        context_stack.pop
      end
    end

    def self.run_shell_cmd(cmd_str, silently=false)
      @job.run_command(cmd_str, silently)
    end

    def self.log(msg)
      @job.write_output do |f|
        f << "\n#{@current_context.join(' ')}:\n\t#{msg}" 
      end
    end

    def self.failed!(msg = "")
      raise Octopusci::JobRunFailed.new(msg)
    end
    
    def self.perform(project_name, branch_name, job_id, job_conf)
      context_stack = []

      # Note: There is no logic for handling stage coming back as nil because
      # it should never happen because there are the same number of resque
      # workers as there are stages at all times.
      if Octopusci::Config.has_key?('stages')
        # Get the next available stage from redis which locks it by removing it
        # from the list of available
        stage = Octopusci::StageLocker.pop
      end
      
      begin
        # Using redis to get the associated github_payload
        github_payload = Octopusci::Queue.github_payload(project_name, branch_name)
        
        @job = ::Job.where("jobs.repo_name = ? && jobs.ref = ?", github_payload['repository']['name'], github_payload['ref']).order('jobs.created_at DESC').first
        if @job
          @job.record_start!(stage)
          
          begin
            @job.clone_code(job_conf)
            @job.checkout_branch(job_conf)
            
            self.run(@job)

            @job.status = 'successful'
          rescue JobHalted => e
            @job.write_exception(e)            
            @job.status = 'failed'
          rescue => e
            @job.write_exception(e)
            @job.status = 'error'
          ensure
            @job.ended_at = Time.new
            @job.save
            Octopusci::Notifier.job_complete(@job, job_conf, @job.successful?)
          end
        end
      ensure
        if Octopusci::Config.has_key?('stages')
          # Unlock the stage by adding it back to the list of available stages
          Octopusci::StageLocker.push(stage)
        end
      end
    end    
  end
end
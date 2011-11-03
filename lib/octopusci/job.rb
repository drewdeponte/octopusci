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

    def self.run_shell_cmd(cmd_str, output_to_log=false)
      @io.write_raw_output(output_to_log) do |out_f|
        out_f << "\n\nRunning: #{cmd_str}\n"
        out_f << "-"*30
        out_f << "\n"
        out_f.flush
      
        in_f = IO.popen(cmd_str)
        while(cur_line = in_f.gets) do
          out_f << cur_line
          out_f.flush
        end

        f.close
      end

      return $?.exitstatus.to_i
    end

    def self.failed!(msg = "")
      raise Octopusci::JobRunFailed.new(msg)
    end

    def self.output(msg)
      @io.write_raw_output(false, msg)
    end

    def self.log(msg)
      @io.write_raw_output(true) do |f|
        f << "\n#{context_stack.join(' ')}:\n\t#{msg}" 
      end
    end

    def self.write_exception(e)
      @io.write_raw_output do |f|
        f << "\n\nException: #{e.message}\n"
        f << "-"*30
        f << "\n"
        f << e.backtrace.join("\n")
      end
    end

    def self.record_start(job, stage)
      job['started_at'] = Time.new
      job['stage'] = stage
      job['status'] = 'running'
      Octopusci::JobStore.set(job['id'], job)
    end

    # def self.code_cloned?
    #   return File.directory?(self.repository_path)
    # end

    # def self.clone_code(job, job_conf)
    #   if self.code_cloned?
    #     return 0
    #   else
    #     if !Dir.exists?(self.workspace_path)
    #       FileUtils.mkdir_p(self.workspace_path)
    #     end
    #     return self.run_command("cd #{self.workspace_path} 2>&1 && git clone #{job_conf['repo_uri']} #{self.repo_name} 2>&1", true)
    #   end
    # end

    # def self.checkout_branch(job, job_conf)
    #   if !self.code_cloned?(job)
    #     self.clone_code(job_conf)
    #   end
      
    #   return self.run_command("cd #{self.repository_path} 2>&1 && git fetch --all -p 2>&1 && git checkout #{self.branch_name} 2>&1 && git pull -f origin #{self.branch_name}:#{self.branch_name} 2>&1", true)
    # end


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
        
        @job = Octopusci::JobStore.list_repo_branch(github_payload['repository']['name'], github_payload['ref'].split('/').last, 0, 1).first
        if @job
          @io = Octopusci::IO.new(@job)
          self.record_start(@job, stage)
          
          begin
        #     self.clone_code(@job, job_conf)
        #     @job.checkout_branch(job_conf)
            
            self.run(@job)

            @job['status'] = 'successful'
          rescue JobHalted => e
            write_exception(e)            
            @job['status'] = 'failed'
          rescue => e
            write_exception(e)
            @job['status'] = 'error'
          ensure
            @job['ended_at'] = Time.new
            Octopusci::JobStore.set(@job['id'], @job)
            # Octopusci::Notifier.job_complete(@job, job_conf, @job.successful?)
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
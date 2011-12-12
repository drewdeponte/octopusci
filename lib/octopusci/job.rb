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
      num_contexts_before = context_stack.length
      context_lead_in = '  '*num_contexts_before
      context_stack.push(desc_str)
      num_contexts_now = context_stack.length
      @output_lead_in = '  '*num_contexts_now
      context_str = context_stack.join(' ')
      output("\n\n#{desc_str}:\n\n")
      begin
        yield
        Octopusci::Notifier.job_complete(@job, get_recip_email(), context_str, true).deliver
      rescue Octopusci::JobRunFailed => e
        write_exception(e)
        Octopusci::Notifier.job_complete(@job, get_recip_email(), context_str, false).deliver
        # setup notification and send notification
        raise JobHalted.new("JobRunFailed:\n  Context: #{context_str}\n  Message: #{e.message}")
      ensure
        context_stack.pop
      end
    end

    def self.run_shell_cmd(cmd_str, output_to_log=false, go_to_repo=true)
      horiz_line = "-"*30
      @io.write_raw_output(output_to_log) do |out_f|
        out_f << "\n\n#{@output_lead_in}Running: #{cmd_str}\n"
        out_f << "#{@output_lead_in}#{horiz_line}"
        out_f << "\n"
        out_f.flush
      
        
        real_cmd_str = ""
        if (go_to_repo)
          real_cmd_str += "cd #{repository_path} 2>&1 && "
        end
        real_cmd_str += cmd_str
        in_f = ::IO.popen(real_cmd_str)
        while(cur_line = in_f.gets) do
          out_f << "#{@output_lead_in}#{cur_line}"
          out_f.flush
        end

        in_f.close
      end

      return $?.exitstatus.to_i
    end

    def self.run_shell_cmd!(cmd_str, output_to_log=false, go_to_repo=true)
      r = self.run_shell_cmd(cmd_str, output_to_log, go_to_repo)
      if (r != 0)
        raise Octopusci::JobRunFailed.new("#{cmd_str} exited with non-zero return value (#{r})")
      else
        return 0
      end
    end

    def self.failed!(msg = "")
      raise Octopusci::JobRunFailed.new(msg)
    end

    def self.output(msg)
      @io.write_raw_output(false, "#{@output_lead_in}#{msg}")
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

    def self.record_start(stage)
      @job['started_at'] = Time.new
      @job['stage'] = stage
      @job['status'] = 'running'
      Octopusci::JobStore.set(@job['id'], @job)
    end

    def self.workspace_path
      return "#{Octopusci::Config['general']['workspace_base_path']}/#{@job['stage']}"
    end

    def self.repository_path
      return "#{workspace_path}/#{@job['repo_name']}"
    end

    def self.clone_code(job_conf)
      if File.directory?(repository_path)
        return 0
      else
        if !Dir.exists?(workspace_path)
          FileUtils.mkdir_p(workspace_path)
        end
        return run_shell_cmd("cd #{workspace_path} 2>&1 && git clone #{job_conf['repo_uri']} #{@job['repo_name']} 2>&1", true, false)
      end
    end

    def self.checkout_branch(job_conf)
      return run_shell_cmd("cd #{repository_path} 2>&1 && git fetch --all -p 2>&1 && git reset --hard && git checkout #{@job['branch_name']} 2>&1 && git pull -f origin #{@job['branch_name']}:#{@job['branch_name']} 2>&1", true, false)
    end

    def self.get_recip_email
      recip_email = nil
      if @job['branch_name'] == 'master'
        recip_email = @job_conf['default_email']
      else
        if @job['payload']['pusher']['email']
          recip_email = @job['payload']['pusher']['email']
        else
          recip_email = @job_conf['default_email']
        end
      end
    end

    def self.perform(project_name, branch_name, job_id, job_conf)
      context_stack = []
      @job_conf = job_conf

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
          record_start(stage)
          
          begin
            clone_code(job_conf)
            checkout_branch(job_conf)
            
            self.run(@job)

            @job['status'] = 'successful'
          rescue JobHalted => e
            @job['status'] = 'failed'
          rescue => e
            write_exception(e)
            @job['status'] = 'error'
          ensure
            @job['ended_at'] = Time.new
            Octopusci::JobStore.set(@job['id'], @job)
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
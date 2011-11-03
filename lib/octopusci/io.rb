module Octopusci
  class IO
    attr_accessor :job

    def initialize(job)
      @job = job
    end

    def read_all_out
      if File.exists?(abs_output_file_path)
        cont = ""
        f = File.open(abs_output_file_path, 'r')
        cont = f.read()
        f.close
        return cont
      else
        return ""
      end
    end

    def read_all_log
      if File.exists?(abs_log_file_path)
        return File.open(abs_log_file_path, 'r').read()
      else
        return ""
      end
    end

    def write_out(msg="", &block)
      write_raw_output(false, msg, &block)
    end

    def write_log(msg="", &block)
      write_raw_output(true, msg, &block)
    end

    def write_raw_output(silently=false, msg="")
      # Make sure that the directory structure is in place for the job output.
      if !File.directory?(abs_output_base_path)
        FileUtils.mkdir_p(abs_output_base_path)
      end
      
      # Run the command and output the output to the job file
      out_f = if silently
        File.open(abs_log_file_path, 'a')
      else
        File.open(abs_output_file_path, 'a')
      end

      yield(out_f) if block_given?
      out_f << msg unless msg.nil? || msg.empty?

      out_f.close
    end

    private

    def abs_output_file_path
      return "#{abs_output_base_path}/output.txt"
    end

    def abs_log_file_path
      return "#{abs_output_base_path}/silent_output.txt"
    end

    def abs_output_base_path
      return "#{Octopusci::Config['general']['workspace_base_path']}/jobs/#{@job['id']}"
    end
  end
end
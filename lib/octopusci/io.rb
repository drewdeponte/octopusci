module Octopusci
  class IO
    attr_accessor :job

    def initialize(job)
      @job = job
    end

    def read_all_out
      if File.exists?(abs_output_file_path)
        return File.open(abs_output_file_path, 'r').read()
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

    private

    def abs_output_file_path
      return "#{abs_output_base_path}/output.txt"
    end

    def abs_log_file_path
      return "#{abs_output_base_path}/silent_output.txt"
    end

    def abs_output_base_path
      return "#{Octopusci::Config['general']['workspace_base_path']}/jobs/#{job.id}"
    end
  end
end
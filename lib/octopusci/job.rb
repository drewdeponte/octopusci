module Octopusci
  class Job
    def self.run(github_payload, stage)
      raise PureVirtualMethod, "The self.commit_run method needs to be defined on your Octopusci::Job."
    end

    def self.perform(project_name, branch_name)
      if Octopusci::CONFIG.has_key?('stages')
        # Get the next available stage from redis which locks it by removing it
        # from the list of available
        stage = Octopusci::StageLocker.pop
      end
            
      begin
        # Using redis to get the associated github_payload
        github_payload = Octopusci::Queue.github_payload(project_name, branch_name)
        
        # Run the commit run and report about status and output
        self.run(github_payload, stage)
      ensure
        if Octopusci::CONFIG.has_key?('stages')
          # Unlock the stage by adding it back to the list of available stages
          Octopusci::StageLocker.push(stage)
        end
      end
    end    
  end
end
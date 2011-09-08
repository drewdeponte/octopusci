module Octopusci
  class Job
    def self.run(github_payload)
      raise PureVirtualMethod, "The self.commit_run method needs to be defined on your Octopusci::Job."
    end

    def self.perform(project_name, branch_name)
      # Using redis to get the associated github_payload
      github_payload = Octopusci::Queue.github_payload(project_name, branch_name)
            
      # Run the commit run and report about status and output
      self.run(github_payload)
    end    
  end
end
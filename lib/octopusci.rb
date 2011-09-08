require 'octopusci/version'
require 'octopusci/notifier'
require 'octopusci/config'

module Octopusci
  class Job
    def self.perform(build_script_path, github_payload)
      # repository_url = github_payload["repository"]["url"]
      # compare_url = github_payload["compare"]
      # 
      # pusher_name = github_payload["pusher"]["name"]
      # pusher_email = github_payload["pusher"]["email"]
      # 
      # puts "------------ BUILDING -------------"
      # puts "repository_name: #{repository_name}"
      # puts "branch_name: #{branch_name}"
      # puts "repository_url: #{repository_url}"
      # puts "compare_url: #{compare_url}"
      # puts "pusher_name: #{pusher_name}"
      # puts "pusher_email: #{pusher_email}"
      # puts "Payload: "
      # puts github_payload.inspect
      # 
      # Run the build commands
      cmd_output = `#{build_script_path}`
      cmd_status = $?

      # Notify about the results
      Notifier.job_complete('cyphactor@gmail.com', cmd_output, cmd_status, github_payload).deliver 
    end
  end
  
  def self.greet
    return "Hello RSpec!"
  end
end
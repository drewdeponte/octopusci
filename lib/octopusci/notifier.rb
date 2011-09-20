require 'action_mailer'

# Set the ActionMailer view_path to lib where this library is so that when
# it searches for class_name/method for the templates it can find them when
# we don't use the standard Rails action mailer view locations.
ActionMailer::Base.view_paths = File.dirname(__FILE__) + '/../'

module Octopusci
  class Notifier < ActionMailer::Base    
    def job_complete(recipient, cmd_output, cmd_status, github_payload, job_id)
      @job = ::Job.find(job_id)
      @job.output = cmd_output
      if cmd_status == 0
        @job.successful = true
      else
        @job.successful = false
      end
      @job.save
      @cmd_output = cmd_output
      @cmd_status = cmd_status
      @github_payload = github_payload
      mail(:to => recipient, :subject => "Octopusci Job Complete") do |format|
        format.text
        format.html
      end
    end
  end
end
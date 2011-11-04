require 'action_mailer'

# Set the ActionMailer view_path to lib where this library is so that when
# it searches for class_name/method for the templates it can find them when
# we don't use the standard Rails action mailer view locations.
ActionMailer::Base.view_paths = File.dirname(__FILE__) + '/../'

module Octopusci
  class Notifier < ActionMailer::Base
    def job_complete(job, recip_email, context_str, success=false)
      @job = job
      @success = success
      @context_str = context_str
      if success
        @status_str = 'success'
      else
        @status_str = 'failed'
      end
            
      mail(:to => recip_email, :subject => "Octopusci Build (#{@status_str}) - #{context_str} - #{@job['repo_name']} / #{@job['branch_name']}") do |format|
        format.html
      end
    end
  end
end
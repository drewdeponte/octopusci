require 'action_mailer'

# Set the ActionMailer view_path to lib where this library is so that when
# it searches for class_name/method for the templates it can find them when
# we don't use the standard Rails action mailer view locations.
ActionMailer::Base.view_paths = File.dirname(__FILE__) + '/../'

module Octopusci
  class Notifier < ActionMailer::Base
    def job_complete(job_rec, job_conf, success=false)
      @job = job_rec
      if success
        @status_str = 'success'
      else
        @status_str = 'failed'
      end
      
      recip_email = nil
      if job_rec.branch_name == 'master'
        recip_email = job_conf['default_email']
      else
        if job_rec.payload['pusher']['email']
          recip_email = job_rec.payload['pusher']['email']
        else
          recip_email = job_conf['default_email']
        end
      end
      
      mail(:to => recip_email, :subject => "Octopusci Build (#{@status_str}) - #{@job.repo_name} / #{@job.branch_name}") do |format|
        format.text
        format.html
      end
    end
  end
end
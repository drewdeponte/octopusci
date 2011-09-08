require 'action_mailer'

SMTP_FROM_EMAIL = 'cyphactor@gmail.com'
SMTP_PASSWORD = 'passw0rd'

# Set the ActionMailer view_path to lib where this library is so that when
# it searches for class_name/method for the templates it can find them when
# we don't use the standard Rails action mailer view locations.
ActionMailer::Base.view_paths = File.dirname(__FILE__)

class Notifier < ActionMailer::Base
  default :from => 'jarrett.baugh@gmail.com'

  def job_complete(recipient, cmd_output, cmd_status)
    @cmd_output = cmd_output
    @cmd_status = cmd_status
    mail(:to => recipient, :from => SMTP_FROM_EMAIL, :subject => "Octopusci Job Complete") do |format|
      format.text
      format.html
    end
  end
end

Notifier.delivery_method = :smtp
Notifier.smtp_settings = {
  :address => "smtp.gmail.com",
  :port => "587",
  # :domain => "YOUR_DOMAIN",       
  :authentication => :plain,
  :enable_starttls_auto => true,
  :user_name => SMTP_FROM_EMAIL,
  :password => SMTP_PASSWORD,
  :raise_delivery_errors => true
}
Notifier.logger = Logger.new(STDOUT)

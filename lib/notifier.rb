require 'action_mailer'

# Set the ActionMailer view_path to lib where this library is so that when
# it searches for class_name/method for the templates it can find them when
# we don't use the standard Rails action mailer view locations.
ActionMailer::Base.view_paths = File.dirname(__FILE__)

class Notifier < ActionMailer::Base
  default :from => 'cyphactor@gmail.com'

  def welcome
    mail(:to => 'adeponte@realpractice.com', :from => 'cyphactor@gmail.com', :subject => "Welcome Notification") do |format|
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
  :user_name => "cyphactor@gmail.com",
  :password => "passw0rd",
  :raise_delivery_errors => true
}
Notifier.logger = Logger.new(STDOUT)

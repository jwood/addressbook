# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Addressbook::Application.initialize!
ActionMailer::Base.smtp_settings = {
  :user_name => 'apikey',
  :password => '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',
  :domain => 'jsc.d8u.us',
  :address => 'smtp.sendgrid.net',
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}


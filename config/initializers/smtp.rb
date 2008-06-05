# SMTP server configuration

ActionMailer::Base.delivery_method = :sendmail
ActionMailer::Base.smtp_settings = {
  :address => '127.0.0.1',
  :port => 25,
  :domain => 'health.spidah.homeip.net',
  :authentication => :login,
  :user_name => 'healtheriser',
  :password => 'healtheriser',
}

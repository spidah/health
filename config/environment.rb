# Be sure to restart your web server when you modify this file.

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Skip frameworks you're not going to use (only works if using vendor/rails)
  config.frameworks -= [ :active_resource ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # Application gems
  config.gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com/'
end

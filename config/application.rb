require File.expand_path('../boot', __FILE__)

require 'rails/all'

module Addressbook
  class Application < Rails::Application
    # Settings in config/environments/* take precedence those specified here
    
    # Skip frameworks you're not going to use (only works if using vendor/rails)
    # config.frameworks -= [ :action_web_service, :action_mailer ]
  
    # Add additional load paths for your own custom dirs
    # config.load_paths += %W( #{RAILS_ROOT}/extras )
  
    # Force all environments to use the same logger level 
    # (by default production uses :info, the others :debug)
    # config.log_level = :debug
  
    # Use the database for sessions instead of the file system
    # (create the session table with 'rake db:sessions:create')
    #config.action_controller.session_store = :active_record_store
  
    # Use SQL instead of Active Record's schema dumper when creating the test database.
    # This is necessary if your schema can't be completely dumped by the schema dumper, 
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql
  
    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector
  
    # Make Active Record use UTC-base instead of local time
    # config.active_record.default_timezone = :utc
    #
 
    config.secret_token = "eba709df22a160581c4806cd0ccf78a877413c87b3521d0873b3591118cac1e56779019f0e0c6ab4259e7e5a4372b64a582d18fd53c60275f9ef1a8c737133ac"

    # See Rails::Configuration for more options

    config.action_view.javascript_expansions[:defaults] = %w(jquery jquery-ui rails application)
  end
end


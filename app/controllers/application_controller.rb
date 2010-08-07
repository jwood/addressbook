require 'app_config'

class ApplicationController < ActionController::Base
  has_mobile_fu

  if ENV['RAILS_ENV'] == 'production'
    htpasswd_file = AppConfig.htpasswd_file
    htpasswd :file => htpasswd_file unless htpasswd_file.blank?
  end
end

class ApplicationController < ActionController::Base
  has_mobile_fu

  if Rails.env == 'production'
    htpasswd_file = Settings.password_file
    htpasswd :file => htpasswd_file unless htpasswd_file.blank?
  end

  def use_mobile_view
    session[:mobile_view] = true
    redirect_to root_path
  end

  def use_desktop_view
    session[:mobile_view] = false
    redirect_to root_path
  end
end

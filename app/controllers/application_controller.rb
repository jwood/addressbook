class ApplicationController < ActionController::Base
  has_mobile_fu

  before_filter :authenticate

  def use_mobile_view
    session[:mobile_view] = true
    redirect_to root_path
  end

  def use_desktop_view
    session[:mobile_view] = false
    redirect_to root_path
  end

  private

    def authenticate
      if Rails.env == 'production'
        username = Settings.username
        password = Settings.password

        if !username.blank? && !password.blank?
          authenticate_or_request_with_http_basic("Addressbook") do |http_username, http_password|
            http_username == username && Password.encode(http_password) == password
          end
        end
      end
    end

end

class SettingsController < ApplicationController

  def edit_address
    @address = Settings.home_address
    render 'address'
  end

  def update_address
    @address = Address.new(params[:address])
    @saved = true if Settings.save_home_address(@address)
    render 'address'
  end

  def edit_login_credentials
    @username = Settings.username
    @password = Settings.password
    @demo = (ENV['DEMO'] == 'true')
    render 'login_credentials'
  end

  def update_login_credentials
    @demo = (ENV['DEMO'] == 'true')
    unless @demo
      @username = params[:username]
      @password = params[:password]
      @password_confirmation = params[:password_confirmation]
      @current_password = params[:current_password]

      current_password = Settings.password
      if !current_password.blank? && Password.encode(@current_password) != current_password
        flash.now[:notice] = 'The current password specified is not valid'
      elsif (@username.blank? || @password.blank? || @password_confirmation.blank?) && !(@username.blank? && @password.blank? && @password_confirmation.blank?)
        flash.now[:notice] = 'You must specify a username, password, and password confirmation'
      elsif @password != @password_confirmation
        flash.now[:notice] = 'The password and password confirmation do not match'
      else
        Settings.username = @username
        Settings.password = @password
        @saved = true
      end
    end
    render 'login_credentials'
  end

end

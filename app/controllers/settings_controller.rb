class SettingsController < ApplicationController

  def address
    @address = Settings.home_address
    if request.post?
      @address = Address.new(params[:address])
      @saved = true if Settings.save_home_address(@address)
    end
  end

  def login_credentials
    @username = Settings.username
    @password = Settings.password
    @demo = (ENV['DEMO'] == 'true')

    if request.post? && !@demo
      @username = params[:username]
      @password = params[:password]
      @password_confirmation = params[:password_confirmation]
      @current_password = params[:current_password]

      current_password = Settings.password
      if !current_password.blank? && Password.encode(@current_password) != current_password
        flash.now[:notice] = 'The current password specified is not valid' and return
      end

      if (@username.blank? || @password.blank? || @password_confirmation.blank?) && !(@username.blank? && @password.blank? && @password_confirmation.blank?)
        flash.now[:notice] = 'You must specify a username, password, and password confirmation' and return
      end

      if @password != @password_confirmation
        flash.now[:notice] = 'The password and password confirmation do not match' and return
      end

      Settings.username = @username
      Settings.password = @password
      @saved = true
    end
  end

end

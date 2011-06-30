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

      message = Settings.update_login_credentials(@username, @password, @password_confirmation, @current_password)
      message.nil? ? @saved = true : flash.now[:notice] = message
    end
    render 'login_credentials'
  end

end

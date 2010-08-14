class SettingsController < ApplicationController

  def address
    @address = Settings.home_address
    if request.post?
      @address = Address.new(params[:address])
      @saved = true if Settings.save_home_address(@address)
    end
  end

  def password_file
    @password_file = Settings.password_file
    if request.post?
      @password_file = params[:password_file]
      if Settings.save_password_file(@password_file)
        @saved = true
      else
        flash.now[:notice] = 'The password file you specified could not be found'
      end
    end
  end

end

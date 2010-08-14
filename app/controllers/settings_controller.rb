class SettingsController < ApplicationController

  def address
    @address = Settings.home_address
    if request.post?
      @address = Address.new(params[:address])
      if @address.valid?
        Settings.save_home_address(@address)
        @saved = true
      end
    end
  end

  def password_file
    @password_file = Settings.password_file
    if request.post?
      @password_file = params[:password_file]
      Settings.save_password_file(@password_file)
      @saved = true
    end
  end

end

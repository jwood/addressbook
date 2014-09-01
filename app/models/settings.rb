class Settings < ActiveRecord::Base

  def self.update_login_credentials(username, password, password_confirmation, current_password)
    actual_current_password = Settings.password
    if !actual_current_password.blank? && Password.create_hash(current_password) != actual_current_password
      'The current password specified is not valid'
    elsif (username.blank? || password.blank? || password_confirmation.blank?) && !(username.blank? && password.blank? && password_confirmation.blank?)
      'You must specify a username, password, and password confirmation'
    elsif password != password_confirmation
      'The password and password confirmation do not match'
    else
      Settings.username = username
      Settings.password = password
      nil
    end
  end

  def self.save_home_address(address)
    if address.valid?
      Settings.update(:address, address.address1)
      Settings.update(:city, address.city)
      Settings.update(:state, address.state)
      Settings.update(:zip, address.zip)
      true
    else
      false
    end
  end

  def self.home_address
    Address.new(:address1 => address, :city => city, :state => state, :zip => zip)
  end

  def self.username
    self.get(:username)
  end

  def self.username=(data)
    Settings.update(:username, data)
  end

  def self.password
    self.get(:password)
  end

  def self.password=(data)
    data = Password.create_hash(data) unless data.blank?
    Settings.update(:password, data)
  end

  def self.address
    self.get(:address)
  end

  def self.city
    self.get(:city)
  end

  def self.state
    self.get(:state)
  end

  def self.zip
    self.get(:zip)
  end

  private

  def self.get(key)
    Settings.find_by_key(key).ergo.value
  end

  def self.update(key, value)
    settings = Settings.find_by_key(key) || Settings.create(:key => key)
    settings.update_attribute(:value, value)
  end

end

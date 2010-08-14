class Settings < ActiveRecord::Base

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

  def self.save_password_file(password_file)
    if password_file.blank? || File.exist?(password_file)
      Settings.update(:password_file, password_file)
      true
    else
      false
    end
  end

  def self.password_file
    self.get(:password_file)
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

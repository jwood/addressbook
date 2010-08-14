require 'test_helper'

class SettingsTest < ActiveSupport::TestCase

  test "should be able to set the application's password file" do
    assert Settings.save_password_file(__FILE__)
    assert_equal __FILE__, Settings.password_file
  end

  test "should not be able to save an invalid address" do
    assert !Settings.save_home_address(Address.new(:address1 => "123 South Ave", :city => "Chicago", :state => "IL"))
  end

  test "should be able to get the home address as an address object" do
    Settings.save_home_address(Address.new(:address1 => "123 South Ave", :city => "Chicago", :state => "IL", :zip => "60606"))
    address = Settings.home_address
    assert_equal Address, address.class
    assert_equal "123 South Ave", address.address1
    assert_equal "Chicago", address.city
    assert_equal "IL", address.state
    assert_equal "60606", address.zip
  end

  test "should not be able to save the password file if the file doesn't exist" do
    assert !Settings.save_password_file("/file/does/not/exist")
  end

end

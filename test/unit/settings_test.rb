require File.dirname(__FILE__) + '/../test_helper'

class SettingsTest < ActiveSupport::TestCase

  context "Settings" do
    should "be able to set the application's username" do
      Settings.username = "bob"
      assert_equal "bob", Settings.username
    end

    should "be able to set the application's password" do
      Settings.password = "mypass"
      assert_equal Password.encode("mypass"), Settings.password
    end

    should "not be able to save an invalid address" do
      assert !Settings.save_home_address(Address.new(:address1 => "123 South Ave", :city => "Chicago", :state => "IL"))
    end

    should "be able to get the home address as an address object" do
      Settings.save_home_address(Address.new(:address1 => "123 South Ave", :city => "Chicago", :state => "IL", :zip => "60606"))
      address = Settings.home_address
      assert_equal Address, address.class
      assert_equal "123 South Ave", address.address1
      assert_equal "Chicago", address.city
      assert_equal "IL", address.state
      assert_equal "60606", address.zip
    end
  end

end

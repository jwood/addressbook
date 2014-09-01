require File.dirname(__FILE__) + '/../test_helper'

class SettingsTest < ActiveSupport::TestCase

  describe "Settings" do
    it "should be able to set the application's username" do
      Settings.username = "bob"
      assert_equal "bob", Settings.username
    end

    it "should be able to set the application's password" do
      Settings.password = "mypass"
      assert_equal Password.create_hash("mypass"), Settings.password
    end

    it "should not be able to save an invalid address" do
      assert !Settings.save_home_address(Address.new(:address1 => "123 South Ave", :city => "Chicago", :state => "IL"))
    end

    it "should be able to get the home address as an address object" do
      Settings.save_home_address(Address.new(:address1 => "123 South Ave", :city => "Chicago", :state => "IL", :zip => "60606"))
      address = Settings.home_address
      assert_equal Address, address.class
      assert_equal "123 South Ave", address.address1
      assert_equal "Chicago", address.city
      assert_equal "IL", address.state
      assert_equal "60606", address.zip
    end

    describe "when working with login credentials" do
      before do
        Settings.username = 'bobby'
        Settings.password = 'pass'
      end

      it "should be able to update the login credentials" do
        msg = Settings.update_login_credentials('bob', 'newpass', 'newpass', 'pass')
        assert_nil msg
        assert_equal 'bob', Settings.username
        assert_equal Password.create_hash('newpass'), Settings.password
      end

      it "should reject if the current password specified is invalid" do
        msg = Settings.update_login_credentials('bob', 'newpass', 'newpass', 'wrongpass')
        assert_equal 'The current password specified is not valid', msg
        assert_equal 'bobby', Settings.username
        assert_equal Password.create_hash('pass'), Settings.password
      end

      it "should reject updates if not all of the required info has been specified" do
        msg = Settings.update_login_credentials('', 'newpass', 'newpass', 'pass')
        assert_equal 'You must specify a username, password, and password confirmation', msg

        msg = Settings.update_login_credentials('bob', nil, 'newpass', 'pass')
        assert_equal 'You must specify a username, password, and password confirmation', msg

        msg = Settings.update_login_credentials('bob', 'newpass', '', 'pass')
        assert_equal 'You must specify a username, password, and password confirmation', msg

        assert_equal 'bobby', Settings.username
        assert_equal Password.create_hash('pass'), Settings.password
      end

      it "should reject update if the password and password confirmation do not match" do
        msg = Settings.update_login_credentials('bob', 'newpass', 'othernewpass', 'pass')
        assert_equal 'The password and password confirmation do not match', msg
        assert_equal 'bobby', Settings.username
        assert_equal Password.create_hash('pass'), Settings.password
      end
    end
  end

end

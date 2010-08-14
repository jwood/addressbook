require 'test_helper'

class SettingsControllerTest < ActionController::TestCase

  test "should be able to get the home address" do
    assert Settings.save_home_address(Address.new(:address1 => "123 South Ave", :city => "Chicago", :state => "IL", :zip => "60606"))

    xhr :get, :address
    assert_equal "123 South Ave", assigns(:address).address1
    assert_equal "Chicago", assigns(:address).city
    assert_equal "IL", assigns(:address).state
    assert_equal "60606", assigns(:address).zip
  end

  test "should be able to update the home address" do
    assert Settings.save_home_address(Address.new(:address1 => "123 South Ave", :city => "Chicago", :state => "IL", :zip => "60606"))

    xhr :post, :address, :address => { :address1 => "555 North Ave", :city => "Tinley Park", :state => "IL", :zip => "60477" }
    assert_equal "555 North Ave", assigns(:address).address1
    assert_equal "Tinley Park", assigns(:address).city
    assert_equal "IL", assigns(:address).state
    assert_equal "60477", assigns(:address).zip    
  end

  test "should not be able to save an invalid address" do
    assert Settings.save_home_address(Address.new(:address1 => "123 South Ave", :city => "Chicago", :state => "IL", :zip => "60606"))

    xhr :post, :address, :address => { :address1 => "555 North Ave", :state => "IL", :zip => "60477" }
    assert !assigns(:address).errors.blank?

    address = Settings.home_address
    assert_equal "123 South Ave", address.address1
    assert_equal "Chicago", address.city
    assert_equal "IL", address.state
    assert_equal "60606", address.zip
  end

  test "should be able to get the password file" do
    assert Settings.save_password_file(__FILE__)
    xhr :get, :password_file
    assert_equal __FILE__, assigns(:password_file)
  end

  test "should be able to set the password file" do
    assert Settings.save_password_file("")
    xhr :post, :password_file, :password_file => __FILE__
    assert_equal __FILE__ , assigns(:password_file)
  end

  test "should not be able to save the password file if the file doens't exist" do
    assert Settings.save_password_file(__FILE__)
    xhr :post, :password_file, :password_file => '/does/not/exist'
    assert_equal 'The password file you specified could not be found', flash.now[:notice]
    assert_equal __FILE__ , Settings.password_file
  end

end

require File.dirname(__FILE__) + '/../test_helper'

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

  test "should be able to get the form to set the username and password" do
    Settings.username = 'bobby'
    Settings.password = 'pass'
    xhr :get, :login_credentials
    assert_response :success
    assert_equal 'bobby', assigns(:username)
    assert_equal Password.encode('pass'), assigns(:password)
  end

  test "should get an error if we didn't specify the username, password, and password confirmation" do
    xhr :post, :login_credentials, :username => 'bob'
    assert_response :success
    assert_equal 'You must specify a username, password, and password confirmation', flash[:notice]
  end

  test "should get an error if the password and the password confirmation do not match" do
    xhr :post, :login_credentials, :username => 'bob', :password => 'mypass', :password_confirmation => 'notmypass'
    assert_response :success
    assert_equal 'The password and password confirmation do not match', flash[:notice]
  end

  test "should be able to successfully set the username and password" do
    xhr :post, :login_credentials, :username => 'bob', :password => 'mypass', :password_confirmation => 'mypass'
    assert_response :success
    assert_equal 'bob', Settings.username
    assert_equal Password.encode('mypass'), Settings.password
  end

  test "should be able to change the username and password" do
    Settings.username = 'bobby'
    Settings.password = 'pass'

    xhr :post, :login_credentials, :username => 'bob', :password => 'mypass', :password_confirmation => 'mypass', :current_password => 'pass'
    assert_response :success
    assert_equal 'bob', Settings.username
    assert_equal Password.encode('mypass'), Settings.password
  end

  test "should be able to successfully blank out the username and password" do
    Settings.username = 'bob'
    Settings.password = 'mypass'

    xhr :post, :login_credentials, :username => '', :password => '', :password_confirmation => '', :current_password => 'mypass'
    assert_response :success

    assert Settings.username.blank?
    assert Settings.password.blank?
  end

end

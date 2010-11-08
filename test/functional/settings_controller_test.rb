require File.dirname(__FILE__) + '/../test_helper'

class SettingsControllerTest < ActionController::TestCase

  context "on GET to :edit_address" do
    setup do
      assert Settings.save_home_address(Address.new(:address1 => "123 South Ave", :city => "Chicago", :state => "IL", :zip => "60606"))
      xhr :get, :edit_address
    end

    should respond_with :success
    should render_template :address
    should "return the home address configured for the application" do
      assert_equal "123 South Ave", assigns(:address).address1
      assert_equal "Chicago", assigns(:address).city
      assert_equal "IL", assigns(:address).state
      assert_equal "60606", assigns(:address).zip
    end
  end

  context "on POST to :update_address with a valid address" do
    setup do
      assert Settings.save_home_address(Address.new(:address1 => "123 South Ave", :city => "Chicago", :state => "IL", :zip => "60606"))
      xhr :post, :update_address, :address => { :address1 => "555 North Ave", :city => "Tinley Park", :state => "IL", :zip => "60477" }
    end

    should respond_with :success
    should render_template :address
    should "set the home address for the application" do
      assert_equal "555 North Ave", assigns(:address).address1
      assert_equal "Tinley Park", assigns(:address).city
      assert_equal "IL", assigns(:address).state
      assert_equal "60477", assigns(:address).zip
    end
  end

  context "on POST to :update_address with an invalid address" do
    setup do
      assert Settings.save_home_address(Address.new(:address1 => "123 South Ave", :city => "Chicago", :state => "IL", :zip => "60606"))
      xhr :post, :update_address, :address => { :address1 => "555 North Ave", :state => "IL", :zip => "60477" }
    end

    should respond_with :success
    should render_template :address
    should("return an error") { assert !assigns(:address).errors.blank? }
    should "still have the old address saved" do
      address = Settings.home_address
      assert_equal "123 South Ave", address.address1
      assert_equal "Chicago", address.city
      assert_equal "IL", address.state
      assert_equal "60606", address.zip
    end
  end

  context "on GET to :edit_login_credentials" do
    setup do
      Settings.username = 'bobby'
      Settings.password = 'pass'
      xhr :get, :edit_login_credentials
    end

    should respond_with :success
    should render_template :login_credentials
    should "return the saved login credentials" do
      assert_equal 'bobby', assigns(:username)
      assert_equal Password.encode('pass'), assigns(:password)
    end
  end

  context "on POST to :update_login_credentials with a missing password and password confirmation" do
    setup { xhr :post, :update_login_credentials, :username => 'bob' }

    should respond_with :success
    should render_template :login_credentials
    should("return an error") { assert_equal 'You must specify a username, password, and password confirmation', flash[:notice] }
  end

  context "on POST to :update_login_credentials with a non matching password and password confirmation" do
    setup { xhr :post, :update_login_credentials, :username => 'bob', :password => 'mypass', :password_confirmation => 'notmypass' }

    should respond_with :success
    should render_template :login_credentials
    should("return an error") { assert_equal 'The password and password confirmation do not match', flash[:notice] }
  end

  context "on POST to :update_login_credentials with a valid username, password, and password confirmation" do
    setup { xhr :post, :update_login_credentials, :username => 'bob', :password => 'mypass', :password_confirmation => 'mypass' }

    should respond_with :success
    should render_template :login_credentials
    should "successfully set the user credentials" do
      assert_equal 'bob', Settings.username
      assert_equal Password.encode('mypass'), Settings.password
    end
  end

  context "on POST to :update_login_credentials when existing login credentials are already set" do
    setup do
      Settings.username = 'bobby'
      Settings.password = 'pass'
      xhr :post, :update_login_credentials, :username => 'bob', :password => 'mypass', :password_confirmation => 'mypass', :current_password => 'pass'
    end

    should respond_with :success
    should render_template :login_credentials
    should "successfully set the user credentials" do
      assert_equal 'bob', Settings.username
      assert_equal Password.encode('mypass'), Settings.password
    end
  end

  context "on POST to :update_login_credentials when trying to change existing credentials but specified the wrong current password" do
    setup do
      Settings.username = 'bobby'
      Settings.password = 'pass'
      xhr :post, :update_login_credentials, :username => 'bob', :password => 'mypass', :password_confirmation => 'mypass', :current_password => 'wrong_pass'
    end

    should respond_with :success
    should render_template :login_credentials
    should("return an error") { assert_equal 'The current password specified is not valid', flash[:notice] }
    should "retain the existing the user credentials" do
      assert_equal 'bobby', Settings.username
      assert_equal Password.encode('pass'), Settings.password
    end
  end

  context "on POST to :update_login_credentials when removing the login credentials" do
    setup do
      Settings.username = 'bob'
      Settings.password = 'mypass'
      xhr :post, :update_login_credentials, :username => '', :password => '', :password_confirmation => '', :current_password => 'mypass'
    end

    should respond_with :success
    should render_template :login_credentials
    should "blank out the user credentials" do
      assert Settings.username.blank?
      assert Settings.password.blank?
    end
  end

end

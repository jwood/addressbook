require File.dirname(__FILE__) + '/../test_helper'

class SettingsControllerTest < ActionController::TestCase
  tests SettingsController

  describe "on GET to :edit_address" do
    before do
      assert Settings.save_home_address(Address.new(:address1 => "123 South Ave", :city => "Chicago", :state => "IL", :zip => "60606"))
      xhr :get, :edit_address
    end

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :address }
    it "should return the home address configured for the application" do
      assert_equal "123 South Ave", assigns(:address).address1
      assert_equal "Chicago", assigns(:address).city
      assert_equal "IL", assigns(:address).state
      assert_equal "60606", assigns(:address).zip
    end
  end

  describe "on PUT to :update_address with a valid address" do
    before do
      assert Settings.save_home_address(Address.new(:address1 => "123 South Ave", :city => "Chicago", :state => "IL", :zip => "60606"))
      xhr :put, :update_address, :address => { :address1 => "555 North Ave", :city => "Tinley Park", :state => "IL", :zip => "60477" }
    end

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :address }
    it "should set the home address for the application" do
      assert_equal "555 North Ave", assigns(:address).address1
      assert_equal "Tinley Park", assigns(:address).city
      assert_equal "IL", assigns(:address).state
      assert_equal "60477", assigns(:address).zip
    end
  end

  describe "on PUT to :update_address with an invalid address" do
    before do
      assert Settings.save_home_address(Address.new(:address1 => "123 South Ave", :city => "Chicago", :state => "IL", :zip => "60606"))
      xhr :put, :update_address, :address => { :address1 => "555 North Ave", :state => "IL", :zip => "60477" }
    end

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :address }
    it("should return an error") { assert !assigns(:address).errors.blank? }
    it "should still have the old address saved" do
      address = Settings.home_address
      assert_equal "123 South Ave", address.address1
      assert_equal "Chicago", address.city
      assert_equal "IL", address.state
      assert_equal "60606", address.zip
    end
  end

  describe "on GET to :edit_login_credentials" do
    before do
      Settings.username = 'bobby'
      Settings.password = 'pass'
      xhr :get, :edit_login_credentials
    end

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :login_credentials }
    it "should return the saved login credentials" do
      assert_equal 'bobby', assigns(:username)
      assert_equal Password.create_hash('pass'), assigns(:password)
    end
  end

  describe "on PUT to :update_login_credentials with a missing password and password confirmation" do
    before { xhr :put, :update_login_credentials, :username => 'bob' }

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :login_credentials }
    it("should return an error") { assert_equal 'You must specify a username, password, and password confirmation', flash[:notice] }
  end

  describe "on PUT to :update_login_credentials with a non matching password and password confirmation" do
    before { xhr :put, :update_login_credentials, :username => 'bob', :password => 'mypass', :password_confirmation => 'notmypass' }

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :login_credentials }
    it("should return an error") { assert_equal 'The password and password confirmation do not match', flash[:notice] }
  end

  describe "on PUT to :update_login_credentials with a valid username, password, and password confirmation" do
    before { xhr :put, :update_login_credentials, :username => 'bob', :password => 'mypass', :password_confirmation => 'mypass' }

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :login_credentials }
    it "should successfully set the user credentials" do
      assert_equal 'bob', Settings.username
      assert_equal Password.create_hash('mypass'), Settings.password
    end
  end

  describe "on PUT to :update_login_credentials when existing login credentials are already set" do
    before do
      Settings.username = 'bobby'
      Settings.password = 'pass'
      xhr :put, :update_login_credentials, :username => 'bob', :password => 'mypass', :password_confirmation => 'mypass', :current_password => 'pass'
    end

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :login_credentials }
    it "should successfully set the user credentials" do
      assert_equal 'bob', Settings.username
      assert_equal Password.create_hash('mypass'), Settings.password
    end
  end

  describe "on PUT to :update_login_credentials when trying to change existing credentials but specified the wrong current password" do
    before do
      Settings.username = 'bobby'
      Settings.password = 'pass'
      xhr :put, :update_login_credentials, :username => 'bob', :password => 'mypass', :password_confirmation => 'mypass', :current_password => 'wrong_pass'
    end

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :login_credentials }
    it("should return an error") { assert_equal 'The current password specified is not valid', flash[:notice] }
    it "should retain the existing the user credentials" do
      assert_equal 'bobby', Settings.username
      assert_equal Password.create_hash('pass'), Settings.password
    end
  end

  describe "on PUT to :update_login_credentials when removing the login credentials" do
    before do
      Settings.username = 'bob'
      Settings.password = 'mypass'
      xhr :put, :update_login_credentials, :username => '', :password => '', :password_confirmation => '', :current_password => 'mypass'
    end

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :login_credentials }
    it "should blank out the user credentials" do
      assert Settings.username.blank?
      assert Settings.password.blank?
    end
  end

end

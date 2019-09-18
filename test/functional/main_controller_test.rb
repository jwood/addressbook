require File.dirname(__FILE__) + '/../test_helper'

class MainControllerTest < ActionController::TestCase
  tests MainController
  include Devise::Test::ControllerHelpers

  describe "on GET to :index" do
    before { get :index }

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :index }
    it("should return the list of contacts") { assert_equal 4, assigns(:contact_list).size }
    it("should return the list of addresses") { assert_equal 4, assigns(:address_list).size }
    it("should return the list of groups") { assert_equal 2, assigns(:group_list).size }
  end

  describe "on GET to :index from a mobile device" do
    before do
      @request.user_agent = "android"
      get :index
    end

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :index }
    it("should return the list of contacts") { assert_equal 4, assigns(:contact_list).size }
  end

  describe "on GET to :use_mobile_view" do
    before { get :use_mobile_view }

    it("should redirect to the root url") { assert_redirected_to(root_url) }
    it("should set the session to indicate we're using a mobile view") { assert_equal true, session[:mobile_view] }
  end

  describe "on GET to :use_desktop_view" do
    before { get :use_desktop_view }

    it("should redirect to the root url") { assert_redirected_to(root_url) }
    it("should set the session to indicate we're using a desktop view") { assert_not_equal true, session[:mobile_view] }
  end

  describe "on interaction with the addressbook" do
    describe "when login credentials are not set" do
      before do
        Rails.env = 'production'
        get :index
        Rails.env = 'test'
      end

      it("should respond with success") { assert_response :success }
      it("should render the proper template") { assert_template :index }
    end

    describe "when login credentials are set" do
      before do
        Settings.username = 'bobby'
        Settings.password = 'pass'
      end

      describe "when user has not yet authenticated" do
        before do
          Rails.env = 'production'
          get :index
          Rails.env = 'test'
        end

        it("should respond with unauthorized") { assert_response 401 }
      end

      describe "when user has authenticated" do
        before do
          @request.env['HTTP_AUTHORIZATION'] = encode_credentials('bobby', 'pass')
          Rails.env = 'production'
          get :index
          Rails.env = 'test'
        end

        it("should respond with success") { assert_response :success }
        it("should render the proper template") { assert_template :index }
      end
    end
  end

  private

    def encode_credentials(username, password)
      "Basic #{Base64.encode64("#{username}:#{password}")}"
    end

end

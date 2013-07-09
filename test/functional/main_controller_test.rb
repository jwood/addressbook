require File.dirname(__FILE__) + '/../test_helper'

class MainControllerTest < ActionController::TestCase
  fixtures :all

  context "on GET to :index" do
    setup { get :index }

    should respond_with :success
    should render_template :index
    should("return the list of contacts") { assert_equal 4, assigns(:contact_list).size }
    should("return the list of addresses") { assert_equal 4, assigns(:address_list).size }
    should("return the list of groups") { assert_equal 2, assigns(:group_list).size }
  end

  context "on GET to :index from a mobile device" do
    setup do
      @request.user_agent = "android"
      get :index
    end

    should respond_with :success
    should render_template :index
    should("return the list of contacts") { assert_equal 4, assigns(:contact_list).size }
  end

  context "on GET to :use_mobile_view" do
    setup { get :use_mobile_view }

    should redirect_to("redirect to the root url") { root_url }
    should("set the session to indicate we're using a mobile view") { assert_equal true, session[:mobile_view] }
  end

  context "on GET to :use_desktop_view" do
    setup { get :use_desktop_view }

    should redirect_to("redirect to the root url") { root_url }
    should("set the session to indicate we're using a desktop view") { assert_not_equal true, session[:mobile_view] }
  end

  context "on interaction with the addressbook" do
    context "when login credentials are not set" do
      setup do
        Rails.env = 'production'
        get :index
        Rails.env = 'test'
      end

      should respond_with :success
      should render_template :index
    end

    context "when login credentials are set" do
      setup do
        Settings.username = 'bobby'
        Settings.password = 'pass'
      end

      context "when user has not yet authenticated" do
        setup do
          Rails.env = 'production'
          get :index
          Rails.env = 'test'
        end

        should respond_with 401
      end

      context "when user has authenticated" do
        setup do
          @request.env['HTTP_AUTHORIZATION'] = encode_credentials('bobby', 'pass')
          Rails.env = 'production'
          get :index
          Rails.env = 'test'
        end

        should respond_with :success
        should render_template :index
      end
    end
  end

  private

    def encode_credentials(username, password)
      "Basic #{Base64.encode64("#{username}:#{password}")}"
    end

end

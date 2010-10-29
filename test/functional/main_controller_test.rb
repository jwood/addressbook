require File.dirname(__FILE__) + '/../test_helper'

class MainControllerTest < ActionController::TestCase

  context "on GET to :index" do
    setup { get :index }

    should respond_with :success
    should render_template :index
    should("return the list of contacts") { assert_equal 4, assigns(:contact_list).size }
    should("return the list of addresses") { assert_equal 4, assigns(:address_list).size }
    should("return the list of groups") { assert_equal 2, assigns(:group_list).size }
  end

end

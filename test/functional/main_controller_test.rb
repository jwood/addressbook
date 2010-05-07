require File.dirname(__FILE__) + '/../test_helper'

class MainControllerTest < ActionController::TestCase

  test "should be able to get the index page of the app" do
    get :index
    assert_template 'index'

    assert_equal(4, assigns(:contact_list).size)
    assert_equal(4, assigns(:address_list).size)
    assert_equal(2, assigns(:group_list).size)
  end

end

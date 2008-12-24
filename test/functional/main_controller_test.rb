require File.dirname(__FILE__) + '/../test_helper'
require 'main_controller'

# Re-raise errors caught by the controller.
class MainController; def rescue_action(e) raise e end; end

class MainControllerTest < Test::Unit::TestCase
  def setup
    @controller = MainController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_template 'index'

    assert_equal(4, assigns(:contact_list).size)
    assert_equal(4, assigns(:address_list).size)
    assert_equal(2, assigns(:group_list).size)
  end
end

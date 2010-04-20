require File.dirname(__FILE__) + '/../test_helper'
require 'address_controller'

# Re-raise errors caught by the controller.
class AddressController; def rescue_action(e) raise e end; end

class AddressControllerTest < ActionController::TestCase
  fixtures :contacts, :addresses, :address_types

  def setup
    @controller = AddressController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_edit_address_get
    xhr :get, :edit_address
    assert_template 'edit_address'
  end

  def test_edit_address_get_with_one_contact
    contact = contacts(:billy_bob)
    address = addresses(:chicago)

    contact.address = address
    contact.save
    contact.address.link_contact

    xhr :get, :edit_address, { :id => address.id }
    assert_template 'edit_address'
  end

  def test_edit_address_post
    address = addresses(:chicago)
    address.address_type_id = address_types(:individual)
    address.address2 = 'Apt 109'
    xhr :post, :edit_address, { :id => address.id, :address => address.attributes }
    assert_template 'edit_address'
    assert_equal(address.address2, assigns(:address).address2)
    assert_equal(true, assigns(:saved))
  end

  def test_delete_address
    address = addresses(:chicago)
    xhr :post, :delete_address, { :id => address.id }
    assert_template 'delete_address'
    assert_equal(address, assigns(:address))
  end
  
end

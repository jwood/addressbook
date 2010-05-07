require File.dirname(__FILE__) + '/../test_helper'

class AddressControllerTest < ActionController::TestCase
  fixtures :all

  test "should be able to get a form to create a new address" do
    xhr :get, :edit_address
    assert_template 'edit_address'
  end

  test "should be able to get an address with a single contact" do
    contact = contacts(:billy_bob)
    address = addresses(:chicago)

    contact.address = address
    contact.save
    contact.address.link_contact

    xhr :get, :edit_address, { :id => address.id }
    assert_template 'edit_address'
  end

  test "should be able to edit an address" do
    address = addresses(:chicago)
    address.address_type = address_types(:individual)
    address.address2 = 'Apt 109'

    xhr :post, :edit_address, { :id => address.id, :address => address.attributes }
    assert_template 'edit_address'
    assert_equal(address.address2, assigns(:address).address2)
    assert_equal(true, assigns(:saved))
    assert_nil assigns(:address_list)
  end

  test "should be able to delete an address" do
    address = addresses(:chicago)
    xhr :post, :delete_address, { :id => address.id }
    assert_template 'delete_address'
    assert_equal(address, assigns(:address))
  end
  
end

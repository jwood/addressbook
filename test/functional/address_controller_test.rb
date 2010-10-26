require File.dirname(__FILE__) + '/../test_helper'

class AddressControllerTest < ActionController::TestCase
  fixtures :all

  context "on GET to :edit_address with no record" do
    setup { xhr :get, :edit_address }

    should respond_with :success
    should render_template :edit_address
  end

  context "on GET to :edit_address with a specific record" do
    setup do
      contact = contacts(:billy_bob)
      @address = addresses(:chicago)

      contact.address = @address
      contact.save
      contact.address.link_contact

      xhr :get, :edit_address, :id => @address
    end

    should respond_with :success
    should render_template :edit_address
    should("return the specified address") { assert_equal @address, assigns(:address) }
  end

  context "on POST to :edit_address" do
    setup do
      @address = addresses(:chicago)
      @address.address_type = address_types(:individual)
      @address.address2 = 'Apt 109'

      xhr :post, :edit_address, :id => @address, :address => @address.attributes
    end

    should respond_with :success
    should render_template :edit_address
    should("return the edited address") { assert_equal @address.address2, assigns(:address).address2 }
    should("indicate the record was saved") { assert_equal true, assigns(:saved) }
    should("not return an updated address list") { assert_nil assigns(:address_list) }
  end

  context "on POST to :delete_address" do
    setup do
      @address = addresses(:chicago)
      xhr :post, :delete_address, :id => @address
    end

    should respond_with :success
    should render_template :delete_address
    should("return the deleted address") { assert_equal @address, assigns(:address) }
  end
  
end

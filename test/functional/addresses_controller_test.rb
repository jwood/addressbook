require File.dirname(__FILE__) + '/../test_helper'

class AddressesControllerTest < ActionController::TestCase
  tests AddressesController

  describe "on GET to :show with a specific record" do
    before do
      contact = contacts(:billy_bob)
      @address = addresses(:chicago)

      contact.address = @address
      contact.save
      contact.address.link_contact

      xhr :get, :show, :id => @address
    end

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :edit_address }
    it("should return the specified address") { assert_equal @address, assigns(:address) }
  end

  describe "on PUT to :update" do
    before do
      @address = addresses(:chicago)
      @address.address_type = address_types(:individual)
      @address.address2 = 'Apt 109'

      xhr :put, :update, :id => @address, :address => @address.attributes
    end

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :edit_address }
    it("should return the edited address") { assert_equal @address.address2, assigns(:address).address2 }
    it("should indicate the record was saved") { assert_equal true, assigns(:saved) }
    it("should not return an updated address list") { assert_nil assigns(:address_list) }
  end

  describe "on DELETE to :destroy" do
    before do
      @address = addresses(:chicago)
      xhr :delete, :destroy, :id => @address
    end

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :delete_address }
    it("should return the deleted address") { assert_equal @address, assigns(:address) }
  end

end

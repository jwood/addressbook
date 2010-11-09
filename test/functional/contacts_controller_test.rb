require File.dirname(__FILE__) + '/../test_helper'

class ContactsControllerTest < ActionController::TestCase
  fixtures :all

  context "on GET to :new" do
    setup { xhr :get, :new }

    should respond_with :success
    should render_template :edit_contact
  end

  context "on GET to :show from a mobile device" do
    setup do
      @request.user_agent = "android"
      get :show, :id => contacts(:john_doe)
    end

    should respond_with :success
    should render_template :show_contact
    should("return the contact") { assert_equal contacts(:john_doe), assigns(:contact) }
  end

  context "on GET to :show from a standard web browser" do
    setup { xhr :get, :show, :id => contacts(:john_doe) }

    should respond_with :success
    should render_template :edit_contact
    should("return the contact") { assert_equal contacts(:john_doe), assigns(:contact) }
  end

  context "on GET to :edit with a specific record" do
    setup { xhr :get, :edit, :id => contacts(:john_doe) }

    should respond_with :success
    should render_template :edit_contact
    should("return the contact to edit") { assert_equal contacts(:john_doe), assigns(:contact) }
  end

  context "on POST to :update to edit a contact's details" do
    setup do
      contact = contacts(:john_doe)
      contact.middle_name = 'Patrick'
      xhr :post, :update, :id => contact, :contact => contact.attributes
    end

    should respond_with :success
    should render_template :edit_contact
    should("be able to edit the contact's middle name") { assert_equal "Patrick", assigns(:contact).middle_name }
    should("indicate the record was saved") { assert_equal true, assigns(:saved) }
  end

  context "on DELETE to :destroy" do
    setup do
      @contact = contacts(:john_doe)
      xhr :delete, :destroy, :id => @contact
    end

    should respond_with :success
    should render_template :delete_contact
    should("return the deleted contact") { assert_equal @contact, assigns(:contact)}
    should("not be able to find the contact in the database") { assert_nil Contact.find_by_id(@contact) }
  end

  context "on DELETE to :destroy when linked to an address" do
    setup do
      @contact = contacts(:john_doe)
      @address = addresses(:alsip)
      @contact.update_attribute(:address, @address)
      xhr :delete, :destroy, :id => @contact
    end

    should respond_with :success
    should render_template :delete_contact
    should("return the deleted contact") { assert_equal @contact, assigns(:contact)}
    should("not be able to find the contact in the database") { assert_nil Contact.find_by_id(@contact) }
    should("delete the address since it has no more contacts") { assert_nil Address.find_by_id(@address) }
    should("return the old address") { assert !addresses(:alsip).different_from?(assigns(:old_address)) }
  end

  context "on POST to :remove_address" do
    setup do
      contact = contacts(:john_doe)
      address = addresses(:chicago)
      contact.update_attribute(:address, address)
      xhr :post, :remove_address, :id => contact
    end

    should respond_with :success
    should render_template :edit_contact
    should("no longer be linked to an address") { assert_nil assigns(:contact).address }
    should("indicate the record was saved") { assert_equal true, assigns(:saved) }
  end

  context "on POST to :find" do
    setup { xhr :post, :find, :last_name => 'd' }

    should respond_with :success
    should render_template :find_contact
    should("return three contacts") { assert_equal 3, assigns(:contact_list).size }
    should("return all contacts with the last name of 'Doe'") {  assert assigns(:contact_list).all { |c| c.last_name == 'Doe' } }
  end

  context "on POST to :update to associate a contact with the address of another contact" do
    setup do
      contacts(:john_doe).update_attribute(:address, addresses(:chicago))
      contacts(:jane_doe).update_attribute(:address, addresses(:alsip))
      contact = contacts(:john_doe)
      xhr :post, :update, :id => contact, :contact => contact.attributes,
        :address_specification_type => "existing_address", :other_id => contacts(:jane_doe).id
    end

    should respond_with :success
    should render_template :edit_contact
    should("indicate the record was saved") { assert_equal true, assigns(:saved) }
    should("set the address of the contact to the address of the other") { assert_equal addresses(:alsip), assigns(:contact).address }
    should("delete the old address of the contact") { assert_nil Address.find_by_id(addresses(:chicago)) }
  end

  context "on POST to :update to assign a new address to an existing contact" do
    setup do
      contact = contacts(:john_doe)
      xhr :post, :update, :id => contact.id, :contact => contact.attributes,
        :address_specification_type => "specified_address", :address => {
          :address1 => "9909 South St.", :address2 => "Apt 2", :city => "Chicago", :state => "IL", :zip => "60606", :home_phone => '1-312-222-1221'}
    end

    should respond_with :success
    should render_template :edit_contact
    should("indicate the record was saved") { assert_equal true, assigns(:saved) }
    should("successfully change the address of the contact") do
      assert_equal('9909 South St.', assigns(:contact).address.address1)
      assert_equal('Apt 2', assigns(:contact).address.address2)
      assert_equal('Chicago', assigns(:contact).address.city)
      assert_equal('IL', assigns(:contact).address.state)
      assert_equal('60606', assigns(:contact).address.zip)
      assert_equal('3122221221', assigns(:contact).address.home_phone)
    end
  end

  context "on POST to :update to assign a bogus adress to an existing contact" do
    setup do
      contact = contacts(:john_doe)
      xhr :post, :update, :id => contact, :contact => contact.attributes,
        :address_specification_type => "specified_address", :address => {
          :address1 => "9909 South St.", :city => "", :state => "Don't know", :zip => "lkjasdflkj"}
    end

    should respond_with :success
    should render_template :edit_contact
    should("not indicate the record was saved") { assert !assigns(:saved) }
    should("not assign the address to the contact") { assert_nil assigns(:contact).address }
    should("include an error message") { assert assigns(:contact).errors.full_messages.include?("Please specify a valid address") }
  end

  context "on POST to :create to create a new contact associating them with the address of another contact" do
    setup do
      contacts(:jane_doe).update_attribute(:address, addresses(:alsip))
      contact = contacts(:john_doe)
      xhr :post, :create, :contact => contact.attributes,
        :address_specification_type => "existing_address", :other_id => contacts(:jane_doe)
    end

    should respond_with :success
    should render_template :edit_contact
    should("indicate the record was saved") { assert_equal true, assigns(:saved) }
    should("assign the proper address to the contact") { assert_equal addresses(:alsip), assigns(:contact).address }
  end

  context "on POST to :create to create a new contact with a specified address" do
    setup do
      contact = contacts(:john_doe)
      xhr :post, :create, :contact => contact.attributes,
        :address_specification_type => "specified_address", :address => {
          :address1 => "9909 South St.", :address2 => "Apt 2", :city => "Chicago", :state => "IL", :zip => "60606", :home_phone => "312-222-1221" }
    end

    should respond_with :success
    should render_template :edit_contact
    should("indicate the record was saved") { assert_equal true, assigns(:saved) }
    should("successfully set the address of the contact") do
      assert_equal('9909 South St.', assigns(:contact).address.address1)
      assert_equal('Apt 2', assigns(:contact).address.address2)
      assert_equal('Chicago', assigns(:contact).address.city)
      assert_equal('IL', assigns(:contact).address.state)
      assert_equal('60606', assigns(:contact).address.zip)
      assert_equal('3122221221', assigns(:contact).address.home_phone)
    end
  end

  context "on POST to :create to create a contact with no address" do
    setup { xhr :post, :create, :contact => contacts(:john_doe).attributes }

    should respond_with :success
    should render_template :edit_contact
    should("indicate the record was saved") { assert_equal true, assigns(:saved) }
    should("return the contact that was created") { assert_not_nil assigns(:contact) }
    should("not set an address for the contact") { assert_nil assigns(:contact).address }
  end

  context "on POST to :create to create a contact with only a home phone number, and no address" do
    setup do
      contact = contacts(:john_doe)
      xhr :post, :create, :id => contact, :contact => contact.attributes,
        :address => { :home_phone => '555-232-2323', :address1 => '', :city => '', :state => '', :zip => '' }
    end

    should respond_with :success
    should render_template :edit_contact
    should("indicate the record was saved") { assert_equal true, assigns(:saved) }
    should("successfully create the contact") { assert_not_nil assigns(:contact) }
    should("set the home phone number for the contact") { assert_equal '5552322323', assigns(:contact).address.home_phone }
  end

  context "on POST to :update to update an existing contact with a new address" do
    setup do
      contacts(:john_doe).update_attribute(:address, addresses(:alsip))
      assert(addresses(:alsip).contacts.include?(contacts(:john_doe)))

      contact = contacts(:john_doe)
      xhr :post, :update, :id => contact, :contact => contact.attributes,
        :address_specification_type => "specified_address", :address => {
          :address1 => "123 Main St", :city => "Chicago", :state => "IL", :zip => "60606"}
    end

    should respond_with :success
    should render_template :edit_contact
    should("indicate the record was saved") { assert_equal true, assigns(:saved) }
    should("retain the id of the current address") { assert_equal addresses(:alsip).id, assigns(:contact).address.id }
    should("update the actual address with the new data") { assert_equal 'Chicago', assigns(:contact).address.city }
  end

  context "on POST to :update to edit the address of a contact that currently has the same address as another contact" do
    setup do
      contacts(:john_doe).update_attribute(:address, addresses(:alsip))
      contacts(:jane_doe).update_attribute(:address, addresses(:alsip))

      contact = contacts(:john_doe)
      xhr :post, :update, :id => contact, :contact => contact.attributes,
        :address_specification_type => "specified_address", :address => {
          :address1 => "123 Main St", :city => "Chicago", :state => "IL", :zip => "60606"}
    end

    should respond_with :success
    should render_template :edit_contact
    should("indicate the record was saved") { assert_equal true, assigns(:saved) }
    should("not change any of the address information just yet...") do
      assert_equal(addresses(:alsip).id, assigns(:contact).address.id)
      assert_equal(addresses(:alsip), contacts(:john_doe).address)
      assert_equal(addresses(:alsip), contacts(:jane_doe).address)
      assert_equal('Chicago', session[:changed_address].city)
    end
  end

  context "on POST to :change_address for an address with multiple contacts" do
    setup do
      contacts(:john_doe).update_attribute(:address, addresses(:alsip))
      contacts(:jane_doe).update_attribute(:address, addresses(:alsip))

      address = addresses(:alsip)
      address.update_attribute(:city, 'Chicago')
      session[:changed_address] = address

      xhr :post, :change_address, { :id => contacts(:john_doe), :submit_id => 'yes' }
    end

    should respond_with :success
    should render_template :edit_contact
    should "update the address of the contacts" do
      assert_equal 'Chicago', contacts(:john_doe).address.city
      assert_equal 'Chicago', contacts(:jane_doe).address.city
    end
    should("not indicate that a new address was added") { assert_nil assigns(:address_list) }
  end

  context "on POST to :change_address for an address change that should only be performed on a single contact" do
    setup do
      contacts(:john_doe).update_attribute(:address, addresses(:alsip))
      contacts(:jane_doe).update_attribute(:address, addresses(:alsip))

      address = addresses(:alsip)
      address.update_attribute(:city, 'Chicago')
      session[:changed_address] = address

      xhr :post, :change_address, { :id => contacts(:john_doe), :submit_id => 'no' }
    end

    should respond_with :success
    should render_template :edit_contact
    should("change the address for the given contact") { assert_equal 'Chicago', contacts(:john_doe).address.city }
    should("keep the address for other contact") { assert_equal addresses(:alsip), contacts(:john_doe).address }
    should("indicate that a new address was added") { assert_not_nil assigns(:address_list) }
  end

end

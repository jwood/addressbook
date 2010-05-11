require File.dirname(__FILE__) + '/../test_helper'

class ContactControllerTest < ActionController::TestCase
  fixtures :all
  
  test "should be able to get a form to create a new contact" do
    xhr :get, :edit_contact
    assert_template 'edit_contact'
  end

  test "should be able to edit a contact" do
    contact = contacts(:john_doe)
    contact.middle_name = 'Patrick'
    xhr :post, :edit_contact, { :id => contact.id, :contact => contact.attributes }
    assert_template 'edit_contact'
    assert_equal(contact.middle_name, assigns(:contact).middle_name)
    assert_equal(true, assigns(:saved))
  end
  
  test "should be able to delete a contact" do
    contact = contacts(:john_doe)
    xhr :post, :delete_contact, { :id => contact.id }
    assert_template 'delete_contact'
    assert_equal(contact, assigns(:contact))
    assert_nil Contact.find_by_id(contacts(:john_doe))
  end

  test "should unlink the contact from its address when deleting the contact" do
    contact = contacts(:john_doe)
    contact.update_attribute(:address, addresses(:alsip))

    xhr :post, :delete_contact, { :id => contact.id }
    assert_template 'delete_contact'
    assert_equal(contact, assigns(:contact))
    assert_nil Contact.find_by_id(contacts(:john_doe))
    assert_nil Address.find_by_id(addresses(:alsip))
  end
  
  test "should be able to remove an address from a contact" do
    contact = contacts(:john_doe)
    address = addresses(:chicago)
    contact.update_attribute(:address, address)
    
    xhr :post, :remove_address_from_contact, { :id => contact.id }
    assert_nil(assigns(:contact).address)
    assert_equal(true, assigns(:saved))
    assert_response :success
  end
  
  test "should be able to find a contact by partial last name" do
    xhr :post, :find_contact, { :last_name => 'd' }
    assert_equal(3, assigns(:contact_list).size)
    assert_template 'find_contact'
    assigns(:contact_list).each { |c| assert_equal('Doe', c.last_name) }
  end
  
  test "should be able to associate a contact with the address of another contact" do
    contacts(:john_doe).update_attribute(:address, addresses(:chicago))
    contacts(:jane_doe).update_attribute(:address, addresses(:alsip))

    contact = contacts(:john_doe)
    xhr :post, :edit_contact, { :id => contact.id, :contact => contact.attributes,
      :address_specification_type => "existing_address", :other_id => contacts(:jane_doe).id }
    assert_template 'edit_contact'
    assert_equal(addresses(:alsip), assigns(:contact).address)
    assert_equal(true, assigns(:saved))
    assert_nil Address.find_by_id(addresses(:chicago).id)
  end

  test "should be able to assign a new address to an existing contact" do
    contact = contacts(:john_doe)
    xhr :post, :edit_contact, { :id => contact.id, :contact => contact.attributes,
      :address_specification_type => "specified_address", :address => {
        :address1 => "9909 South St.", :address2 => "Apt 2", :city => "Chicago", :state => "IL", :zip => "60606", :home_phone => '1-312-222-1221'} }
    assert_template 'edit_contact'
    assert_equal('9909 South St.', assigns(:contact).address.address1)
    assert_equal('Apt 2', assigns(:contact).address.address2)
    assert_equal('Chicago', assigns(:contact).address.city)
    assert_equal('IL', assigns(:contact).address.state)
    assert_equal('60606', assigns(:contact).address.zip)
    assert_equal('3122221221', assigns(:contact).address.home_phone)
    assert_equal(true, assigns(:saved))
  end

  test "assigning a bogus address to an existing contact should result in an error" do
    contact = contacts(:john_doe)
    xhr :post, :edit_contact, { :id => contact.id, :contact => contact.attributes,
      :address_specification_type => "specified_address", :address => {
        :address1 => "9909 South St.", :city => "", :state => "Don't know", :zip => "lkjasdflkj"} }
    assert_template 'edit_contact'
    assert_nil assigns(:contact).address
    assert assigns(:contact).errors.full_messages.include?("Please specify a valid address")
    assert !assigns(:saved)
  end

  test "should be able to create a new contact, associating them with the address of another contact" do
    contacts(:jane_doe).update_attribute(:address, addresses(:alsip))

    contact = contacts(:john_doe)
    xhr :post, :edit_contact, { :contact => contact.attributes,
      :address_specification_type => "existing_address", :other_id => contacts(:jane_doe).id }
    assert_template 'edit_contact'
    assert_equal(addresses(:alsip), assigns(:contact).address)
    assert_equal(true, assigns(:saved))
  end

  test "should be able to create a new contact with the specified address" do
    contact = contacts(:john_doe)
    xhr :post, :edit_contact, { :contact => contact.attributes,
      :address_specification_type => "specified_address", :address => {
        :address1 => "9909 South St.", :city => "", :state => "Don't know", :zip => "lkjasdflkj"} }
    assert_template 'edit_contact'
    assert_nil assigns(:contact).address
    assert assigns(:contact).errors.full_messages.include?("Please specify a valid address")
    assert !assigns(:saved)
  end

  test "should be able to create a contact with no address" do
    contact = contacts(:john_doe)
    xhr :post, :edit_contact, { :contact => contact.attributes }
    assert_template 'edit_contact'
    assert_not_nil assigns(:contact)
    assert_nil assigns(:contact).address
    assert assigns(:saved)
  end

  test "should be able to create a contact with only a home phone number, and no address" do
    contact = contacts(:john_doe)
    xhr :post, :edit_contact, { :id => contact.id, :contact => contact.attributes,
      :address => { :home_phone => '555-232-2323', :address1 => '', :city => '', :state => '', :zip => '' } }
    assert_template 'edit_contact'
    assert_not_nil assigns(:contact)
    assert_equal '5552322323', assigns(:contact).address.home_phone
    assert assigns(:saved)
  end

  test "should be able to update an existing contact with a new address" do
    contacts(:john_doe).update_attribute(:address, addresses(:alsip))
    assert(addresses(:alsip).contacts.include?(contacts(:john_doe)))

    contact = contacts(:john_doe)
    xhr :post, :edit_contact, { :id => contact.id, :contact => contact.attributes,
      :address_specification_type => "specified_address", :address => {
        :address1 => "123 Main St", :city => "Chicago", :state => "IL", :zip => "60606"} }
    assert_template 'edit_contact'
    assert_equal(addresses(:alsip).id, assigns(:contact).address.id)
    assert_equal('Chicago', assigns(:contact).address.city)
    assert_equal(true, assigns(:saved))
  end

  test "edit the address of a contact that currently has the same address as another contact" do
    contacts(:john_doe).update_attribute(:address, addresses(:alsip))
    contacts(:jane_doe).update_attribute(:address, addresses(:alsip))

    contact = contacts(:john_doe)
    xhr :post, :edit_contact, { :id => contact.id, :contact => contact.attributes,
      :address_specification_type => "specified_address", :address => {
        :address1 => "123 Main St", :city => "Chicago", :state => "IL", :zip => "60606"} }
    assert_template 'edit_contact'

    assert_equal(addresses(:alsip).id, assigns(:contact).address.id)
    assert_equal(addresses(:alsip), contacts(:john_doe).address)
    assert_equal(addresses(:alsip), contacts(:jane_doe).address)
    assert_equal('Chicago', session[:changed_address].city)
    assert_equal(true, assigns(:saved))
  end

  test "confirm that a change of address for multiple contacts should be performed for all contacts" do
    contacts(:john_doe).update_attribute(:address, addresses(:alsip))
    contacts(:jane_doe).update_attribute(:address, addresses(:alsip))

    address = addresses(:alsip)
    address.update_attribute(:city, 'Chicago')
    session[:changed_address] = address

    xhr :post, :change_address_for_contact, { :id => contacts(:john_doe), :submit_id => 'yes' }
    assert_response :success
    assert_template 'edit_contact'

    assert_equal 'Chicago', contacts(:john_doe).address.city
    assert_equal 'Chicago', contacts(:jane_doe).address.city
    assert_nil assigns(:address_list)
  end

  test "confirm that a change of address for multiple contacts should only be performed for the given contact" do
    contacts(:john_doe).update_attribute(:address, addresses(:alsip))
    contacts(:jane_doe).update_attribute(:address, addresses(:alsip))

    address = addresses(:alsip)
    address.update_attribute(:city, 'Chicago')
    session[:changed_address] = address

    xhr :post, :change_address_for_contact, { :id => contacts(:john_doe), :submit_id => 'no' }
    assert_response :success
    assert_template 'edit_contact'

    assert_equal 'Chicago', contacts(:john_doe).address.city
    assert_equal addresses(:alsip), contacts(:jane_doe).address
    assert_not_nil assigns(:address_list)
  end

end

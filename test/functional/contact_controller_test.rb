require File.dirname(__FILE__) + '/../test_helper'

class ContactControllerTest < ActionController::TestCase
  fixtures :contacts, :addresses
  
  def test_edit_contact_get
    xhr :get, :edit_contact
    assert_template 'edit_contact'
  end

  def test_edit_contact_post
    contact = contacts(:john_doe)
    contact.middle_name = 'Patrick'
    xhr :post, :edit_contact, { :id => contact.id, :contact => contact.attributes }
    assert_template 'edit_contact'
    assert_equal(contact.middle_name, assigns(:contact).middle_name)
    assert_equal(true, assigns(:saved))
  end
  
  def test_delete_contact
    contact = contacts(:john_doe)
    xhr :post, :delete_contact, { :id => contact.id }
    assert_template 'delete_contact'
    assert_equal(contact, assigns(:contact))
  end
  
  def test_remove_address_from_contact
    contact = contacts(:john_doe)
    address = addresses(:chicago)
    contact.update_attribute(:address, address)
    
    xhr :post, :remove_address_from_contact, { :id => contact.id }
    assert_nil(assigns(:contact).address)
    assert_equal(true, assigns(:saved))
    assert_response :success
  end
  
  def test_find_contact
    xhr :post, :find_contact, { :last_name => 'd' }
    assert_equal(3, assigns(:contact_list).size)
    assert_template 'find_contact'
    assigns(:contact_list).each { |c| assert_equal('Doe', c.last_name) }
  end
  
  def test_edit_that_associates_contact_with_the_address_of_another_contact
    contacts(:jane_doe).update_attribute(:address, addresses(:alsip))

    contact = contacts(:john_doe)
    xhr :post, :edit_contact, { :id => contact.id, :contact => contact.attributes,
      :address_specification_type => "existing_address", :other_id => contacts(:jane_doe).id }
    assert_template 'edit_contact'
    assert_equal(addresses(:alsip), assigns(:contact).address)
    assert_equal(true, assigns(:saved))
  end
  
  def test_edit_that_assigns_a_new_address_to_an_existing_contact
    contact = contacts(:john_doe)
    xhr :post, :edit_contact, { :id => contact.id, :contact => contact.attributes,
      :address_specification_type => "specified_address", :address => {
        :address1 => "9909 South St.", :address2 => "Apt 2", :city => "Chicago", :state => "IL", :zip => "60606", :home_phone => '312-222-1221'} }
    assert_template 'edit_contact'
    assert_equal('9909 South St.', assigns(:contact).address.address1)
    assert_equal('Apt 2', assigns(:contact).address.address2)
    assert_equal('Chicago', assigns(:contact).address.city)
    assert_equal('IL', assigns(:contact).address.state)
    assert_equal('60606', assigns(:contact).address.zip)
    assert_equal('312-222-1221', assigns(:contact).address.home_phone)
    assert_equal(true, assigns(:saved))
  end

  def test_assining_a_bogus_address_to_an_existing_contact_results_in_an_error
    contact = contacts(:john_doe)
    xhr :post, :edit_contact, { :id => contact.id, :contact => contact.attributes,
      :address_specification_type => "specified_address", :address => {
        :address1 => "9909 South St.", :city => "", :state => "Don't know", :zip => "lkjasdflkj"} }
    assert_template 'edit_contact'
    assert_nil assigns(:contact).address
    assert assigns(:contact).errors.full_messages.include?("Please specify a valid address")
    assert_nil assigns(:saved)
  end

  def test_create_contact_with_address_of_another_contact
    contacts(:jane_doe).update_attribute(:address, addresses(:alsip))

    contact = contacts(:john_doe)
    xhr :post, :edit_contact, { :contact => contact.attributes,
      :address_specification_type => "existing_address", :other_id => contacts(:jane_doe).id }
    assert_template 'edit_contact'
    assert_equal(addresses(:alsip), assigns(:contact).address)
    assert_equal(true, assigns(:saved))
  end

  def test_create_contact_with_new_address
    contact = contacts(:john_doe)
    xhr :post, :edit_contact, { :contact => contact.attributes,
      :address_specification_type => "specified_address", :address => {
        :address1 => "9909 South St.", :city => "", :state => "Don't know", :zip => "lkjasdflkj"} }
    assert_template 'edit_contact'
    assert_nil assigns(:contact).address
    assert assigns(:contact).errors.full_messages.include?("Please specify a valid address")
    assert_nil assigns(:saved)
  end

  def test_update_contact_with_new_address
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

end

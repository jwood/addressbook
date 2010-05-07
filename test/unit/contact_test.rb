require File.dirname(__FILE__) + '/../test_helper'

class ContactTest < ActiveSupport::TestCase
  fixtures :all

  test "should not be able to create a contact with missing required info" do
    contact = Contact.new
    assert !contact.valid?
    assert contact.errors.on(:first_name).include?(I18n.translate('activerecord.errors.messages')[:blank])
    assert contact.errors.on(:last_name).include?(I18n.translate('activerecord.errors.messages')[:blank])
    assert contact.errors.on(:prefix).include?(I18n.translate('activerecord.errors.messages')[:blank])
  end

  test "should null out the contact's address when destroying a contact" do
    contact = contacts(:john_doe)
    address = addresses(:chicago)
    contact.address = address
    contact.save
    assert_not_nil(contact.address)

    contact.destroy
    assert_nil(contact.address)
  end

  test "should not be able to update a contact with an invalid phone number" do
    contact = contacts(:john_doe)
    contact.cell_phone = 'abcd'
    assert !contact.valid?
    assert contact.errors.on(:cell_phone).include?('must be in the format of XXX-XXX-XXXX')
  end

  test "should be able to find all contacts for listing in the app" do
    contacts = Contact.find_for_list
    assert_equal(4, contacts.size)
    assert_equal(contacts(:billy_bob), contacts[0])
    assert_equal(contacts(:jane_doe), contacts[1])
    assert_equal(contacts(:jimmy_doe), contacts[2])
    assert_equal(contacts(:john_doe), contacts[3])
  end

end

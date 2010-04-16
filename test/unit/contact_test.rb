require File.dirname(__FILE__) + '/../test_helper'

class ContactTest < ActiveSupport::TestCase
  fixtures :contacts, :addresses

  def test_creation_without_required_info
    contact = Contact.new
    assert !contact.valid?
    assert contact.errors.on(:first_name).include?(I18n.translate('activerecord.errors.messages')[:blank])
    assert contact.errors.on(:last_name).include?(I18n.translate('activerecord.errors.messages')[:blank])
    assert contact.errors.on(:prefix).include?(I18n.translate('activerecord.errors.messages')[:blank])
  end
  
  def test_deletion_of_contact_linked_to_address
    contact = contacts(:john_doe)
    address = addresses(:chicago)
    contact.address = address
    contact.save
    assert_not_nil(contact.address)

    contact.destroy
    assert_nil(contact.address)
  end

  def test_update_with_invalid_phone_numbers
    contact = contacts(:john_doe)
    contact.cell_phone = 'abcd'
    assert !contact.valid?
    assert contact.errors.on(:cell_phone).include?('must be in the format of XXX-XXX-XXXX')
  end

  def test_find_for_list
    contacts = Contact.find_for_list
    assert_equal(4, contacts.size)
    assert_equal(contacts(:billy_bob), contacts[0])
    assert_equal(contacts(:jane_doe), contacts[1])
    assert_equal(contacts(:jimmy_doe), contacts[2])
    assert_equal(contacts(:john_doe), contacts[3])
  end

end

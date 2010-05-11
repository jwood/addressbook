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
    contact.work_phone = '972-2ou234=234'
    assert !contact.valid?
    assert contact.errors.on(:cell_phone).include?('is not valid')
    assert contact.errors.on(:work_phone).include?('is not valid')
  end

  test "should be able to find all contacts for listing in the app" do
    contacts = Contact.find_for_list
    assert_equal(4, contacts.size)
    assert_equal(contacts(:billy_bob), contacts[0])
    assert_equal(contacts(:jane_doe), contacts[1])
    assert_equal(contacts(:jimmy_doe), contacts[2])
    assert_equal(contacts(:john_doe), contacts[3])
  end

  test "should scrub the phone numbers before saving them to the database" do
    contact = contacts(:john_doe)
    contact.work_phone = '312-555-1212'
    contact.cell_phone = '(312) 555.1213'
    contact.save!

    assert_equal '3125551212', contact.work_phone
    assert_equal '3125551213', contact.cell_phone
  end

  test "assigning a contact to a new address should first unlink the contact from an existing address" do
    contact = contacts(:john_doe)
    contact.update_attribute(:address, addresses(:chicago))
    contact.assign_address(addresses(:alsip))
    contact.save!

    contact.reload
    assert_equal addresses(:alsip), contact.address
    assert_nil Address.find_by_id(addresses(:chicago))
  end

  test "should be able to remove an address from a contact" do
    contact = contacts(:john_doe)
    contact.update_attribute(:address, addresses(:chicago))
    assert addresses(:chicago).contacts.include?(contact)

    old_address_id = addresses(:chicago).id
    assert_equal old_address_id, contact.remove_address
    assert !addresses(:chicago).contacts(true).include?(contact)
  end

end

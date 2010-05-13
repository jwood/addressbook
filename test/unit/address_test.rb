require File.dirname(__FILE__) + '/../test_helper'

class AddressTest < ActiveSupport::TestCase
  fixtures :all

  def setup
    @address = addresses(:chicago)
    @num_address_fixtures = 4
  end

  test "should not be able to create an address without all required info" do
    address = Address.new
    assert !address.valid?
    assert address.errors.on(:base).include?('You must specify a phone number or a full address')
  end

  test "should not be able to update an address with an invalid phone number" do
    @address.home_phone = '(312) xxx-3333'
    assert !@address.valid?
    assert @address.errors.on(:home_phone).include?('is not valid')
  end

  test "an adress with no contacts should simply list the street address as the addressee" do
    assert_equal('123 Main St. Apt. 109, Chicago, IL 60606', @address.addressee)
  end

  test "an address with no street address and no contacts should list the phone number as the addressee" do
    address = addresses(:phone_only)
    assert_equal('708-111-3333', address.addressee)
  end

  test "an address for a single contact should list that contact's name as the addressee" do
    @address.primary_contact = contacts(:john_doe)
    @address.address_type = address_types(:individual)
    assert_equal('Mr. John Doe', @address.addressee)
  end

  test "an address for a married couple should list both the contacts' names as the addressee" do
    @address.primary_contact = contacts(:john_doe)
    @address.secondary_contact = contacts(:jane_doe)
    @address.address_type = address_types(:married_couple)
    assert_equal('Mr. & Mrs. John & Jane Doe', @address.addressee)
  end

  test "an address for a family should list the family name as the addressee" do
    @address.primary_contact = contacts(:john_doe)
    @address.secondary_contact = contacts(:jane_doe)
    @address.address_type = address_types(:family)
    assert_equal('The Doe Family', @address.addressee)
  end

  test "an address for an unmarried couple should list both contacts first and last names as the addressee" do
    @address.primary_contact = contacts(:john_doe)
    @address.secondary_contact = contacts(:jane_doe)
    @address.address_type = address_types(:unmarried_couple)
    assert_equal('Mr. John Doe & Mrs. Jane Doe', @address.addressee)
  end

  test "an address for a single parent should list the family name as the addressee" do
    @address.primary_contact = contacts(:john_doe)
    @address.address_type = address_types(:single_parent)
    assert_equal('The Doe Family', @address.addressee)
  end

  test "an address with no contacts should list the street address as the addressee for display" do
    assert_equal('123 Main St. Apt. 109, Chicago, IL 60606', @address.addressee_for_display)
  end

  test "an address with only a phone number should list the phone number as the addressee for display" do
    address = addresses(:phone_only)
    assert_equal('708-111-3333', address.addressee_for_display)
  end

  test "an address for an individual should list that contact's name as the addressee for display" do
    @address.primary_contact = contacts(:john_doe)
    @address.address_type = address_types(:individual)
    assert_equal('Doe, Mr. John', @address.addressee_for_display)
  end

  test "an address for a married couple should list both contacts as the addressee for display" do
    @address.primary_contact = contacts(:john_doe)
    @address.secondary_contact = contacts(:jane_doe)
    @address.address_type = address_types(:married_couple)
    assert_equal('Doe, Mr. & Mrs. John & Jane', @address.addressee_for_display)
  end

  test "an address for a family should list the primary contacts and family name as the addressee for display" do
    @address.primary_contact = contacts(:john_doe)
    @address.secondary_contact = contacts(:jane_doe)
    @address.address_type = address_types(:family)
    assert_equal('Doe, Mr. & Mrs. John & Jane & Family', @address.addressee_for_display)
  end

  test "an address for an unmarried couple should list both contacts first and last names as the addressee for display" do
    @address.primary_contact = contacts(:john_doe)
    @address.secondary_contact = contacts(:jane_doe)
    @address.address_type = address_types(:unmarried_couple)
    assert_equal('Doe, Mr. John Doe & Mrs. Jane', @address.addressee_for_display)
  end

  test "an address for a single parent should list the contact name and the family name in the addressee for display" do
    @address.primary_contact = contacts(:john_doe)
    @address.address_type = address_types(:single_parent)
    assert_equal('Doe, Mr. John & Family', @address.addressee_for_display)
  end

  test "should be able to find all addresses to list in the app" do
    chicago = addresses(:chicago)
    chicago.primary_contact = contacts(:john_doe)
    chicago.secondary_contact = contacts(:jane_doe)
    chicago.save

    alsip = addresses(:alsip)
    alsip.primary_contact = contacts(:jimmy_doe)
    alsip.save

    tinley_park = addresses(:tinley_park)
    tinley_park.secondary_contact = contacts(:billy_bob)
    tinley_park.save

    addresses = Address.find_for_list
    assert_equal(@num_address_fixtures, addresses.size)
    assert_equal(addresses(:alsip), addresses[0])
    assert_equal(addresses(:chicago), addresses[1])
    assert_equal(addresses(:tinley_park), addresses[2])
    assert_equal(addresses(:phone_only), addresses[3])
  end

  test "should be able to find all addresses eligible to be a member in a group" do
    addresses = Address.eligible_for_group
    assert_equal(@num_address_fixtures - 1, addresses.size)
    assert(addresses.include?(addresses(:chicago)))
    assert(addresses.include?(addresses(:alsip)))
    assert(addresses.include?(addresses(:tinley_park)))

    assert(!addresses.include?(addresses(:phone_only)))
  end

  test "should be able to unlink a contact from an address and delete the address if it only contains one contact" do
    john = contacts(:john_doe)

    assert_equal(0, @address.contacts.size)
    john.address_id = @address.id; john.save; @address.contacts << john; @address.save; @address.link_contact
    assert_equal(1, @address.contacts.size)
    assert_equal(john.id, @address.contact1_id)

    john.address_id = nil; john.save
    @address.unlink_contact(john)

    assert_nil Address.find_by_id(@address.id)
  end

  test "should be able to unlink the secondary contact from an address, adjusting the main contacts accordingly" do
    setup_link_unlink_test

    # Jane moves out
    @jane.address_id = nil; @jane.save
    @address.unlink_contact(@jane)

    assert_equal(2, @address.contacts.size)
    assert_equal(@john.id, @address.contact1_id)
    assert_equal(@jimmy.id, @address.contact2_id)
  end
  
  test "should be able to unlink the primary contact from an address, adjusting the main contacts accordingly" do
    setup_link_unlink_test

    # John moves out
    @john.address_id = nil; @john.save
    @address.unlink_contact(@john)

    assert_equal(2, @address.contacts.size)
    assert_equal(@jimmy.id, @address.contact1_id)
    assert_equal(@jane.id, @address.contact2_id)
  end

  test "should be able to unlink the secondary and primary contacts from an address, adjusting the main contacts accordingly" do
    setup_link_unlink_test

    # John moves out
    @john.address_id = nil; @john.save
    @address.unlink_contact(@john)

    # Jane moves out
    @jane.address_id = nil; @jane.save
    @address.unlink_contact(@jane)

    assert_equal(1, @address.contacts.size)
    assert_equal(@jimmy.id, @address.contact1_id)
  end

  test "should nullify the contact's address id if an address is deleted" do
    setup_link_unlink_test
    @address.destroy
    [@jimmy, @john, @jane].each do |contact|
      contact.reload
      assert_nil(contact.address)
    end
  end

  test "addresses with no primary contacts should be considered equal when sorted" do
    chicago = addresses(:chicago)
    alsip = addresses(:alsip)
    assert_equal(0, chicago.compare_by_primary_contact(alsip))
  end

  test "addresses with primary contacts should appear before addresses without primary contacts when sorted" do
    chicago = addresses(:chicago)
    alsip = addresses(:alsip)

    chicago.primary_contact = contacts(:john_doe)
    alsip.primary_contact = nil
    assert_equal(-1, chicago.compare_by_primary_contact(alsip))

    chicago.primary_contact = nil
    alsip.primary_contact = contacts(:john_doe)
    assert_equal(1, chicago.compare_by_primary_contact(alsip))
  end

  test "addresses that both contain primary contacts should be sorted by the name of their primary contacts" do
    chicago = addresses(:chicago)
    chicago.primary_contact = contacts(:john_doe)

    alsip = addresses(:alsip)
    alsip.primary_contact = contacts(:jane_doe)

    assert_equal(0, chicago.compare_by_primary_contact(chicago))
    assert_equal(-1, alsip.compare_by_primary_contact(chicago))
    assert_equal(1, chicago.compare_by_primary_contact(alsip))
  end

  test "should not be able to compare an address with something that is not an Address" do
    assert_raise ArgumentError do
      @address.compare_by_primary_contact("not an address")
    end
  end

  test "addresses with no information or only a home phone number should be considered empty" do
    assert Address.new.is_address_empty?
    assert Address.new(:home_phone => '312-555-1212').is_address_empty?
    assert !addresses(:alsip).is_address_empty?
  end

  test "address with no street address but a valid home phone should not be considered empty" do
    assert Address.new.is_empty?
    assert !Address.new(:home_phone => '312-555-1212').is_empty?
    assert !addresses(:alsip).is_empty?
  end

  test "should be able to get the mailing address for an address" do
    assert_equal "123 Main St., Apt. 109, Chicago, IL 60606", addresses(:chicago).mailing_address
    assert_equal "456 Maple Ave., Alsip, IL 60803", addresses(:alsip).mailing_address
  end

  test "should be able to determine if one address is different from another" do
    assert addresses(:alsip).different_from?(addresses(:chicago))
    assert addresses(:alsip).different_from?(nil)
    assert addresses(:alsip).different_from?(Address.new)
    assert addresses(:alsip).different_from?(Address.new(addresses(:alsip).attributes.merge(:address2 => 'Apt 102')))

    assert !addresses(:alsip).different_from?(addresses(:alsip))
    assert !addresses(:alsip).different_from?(Address.new(addresses(:alsip).attributes.merge(:id => nil)))
  end

  test "should scrub the phone numbers before saving them to the database" do
    address = addresses(:alsip)
    address.home_phone = '(312) 555.1213'
    address.save!
    assert_equal '3125551213', address.home_phone
  end

  test "should be able to easily tell if an address only has one contact" do
    assign_contact_to_address(contacts(:john_doe), addresses(:chicago))
    assert addresses(:chicago).only_has_one_contact?

    assign_contact_to_address(contacts(:jane_doe), addresses(:chicago))
    assert !addresses(:chicago).only_has_one_contact?
  end

  test "should not be able to edit the address type of an address without the required primary and secondary contacts" do
    assign_contact_to_address(contacts(:john_doe), addresses(:chicago))

    address = addresses(:chicago)
    address.address_type = address_types(:family)
    assert !address.valid?
    assert address.errors.full_messages.include?("This address type requires primary and secondary contacts be specified")

    address.address_type = address_types(:married_couple)
    assert !address.valid?
    assert address.errors.full_messages.include?("This address type requires primary and secondary contacts be specified")

    address.address_type = address_types(:unmarried_couple)
    assert !address.valid?
    assert address.errors.full_messages.include?("This address type requires primary and secondary contacts be specified")
  end

  private

    def assign_contact_to_address(contact, address)
      contact.assign_address(address)
      contact.save
    end

    def setup_link_unlink_test
      @john = contacts(:john_doe)
      @jane = contacts(:jane_doe)
      @jimmy = contacts(:jimmy_doe)

      assert_equal(0, @address.contacts.size)

      [@john, @jane, @jimmy].each do |contact|
        contact.address_id = @address.id
        contact.save
        @address.contacts << contact
        @address.save
        @address.link_contact
      end

      assert_equal(3, @address.contacts.size)
      assert_equal(@john.id, @address.contact1_id)
      assert_equal(@jane.id, @address.contact2_id)
    end
  
end

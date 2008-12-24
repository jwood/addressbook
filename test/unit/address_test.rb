require File.dirname(__FILE__) + '/../test_helper'

require 'rubygems'
require 'rabels'

class AddressTest < Test::Unit::TestCase
  fixtures :contacts, :addresses, :address_types

  def setup
    @address = addresses(:chicago)
    @num_address_fixtures = 4
  end
  
  def test_creation_without_required_info
    address = Address.new
    assert !address.valid?
    assert address.errors.on(:base).include?('You must specify a phone number or a full address')
  end

  def test_update_with_invalid_phone_number
    @address.home_phone = '(312) 222-3333'
    assert !@address.valid?
    assert @address.errors.on(:home_phone).include?('must be in the format of XXX-XXX-XXXX')
  end
  
  def test_addressee_with_no_contacts
    assert_equal('123 Main St. Apt. 109, Chicago, IL 60606', @address.addressee)
  end
  
  def test_addressee_with_phone_only
    address = addresses(:phone_only)
    assert_equal('708-111-3333', address.addressee)
  end

  def test_addressee_with_individual
    @address.primary_contact = contacts(:john_doe)
    @address.address_type = address_types(:individual)
    assert_equal('Mr. John Doe', @address.addressee)
  end
  
  def test_addressee_with_married_couple
    @address.primary_contact = contacts(:john_doe)
    @address.secondary_contact = contacts(:jane_doe)
    @address.address_type = address_types(:married_couple)
    assert_equal('Mr. & Mrs. John & Jane Doe', @address.addressee)
  end
  
  def test_addressee_with_family
    @address.primary_contact = contacts(:john_doe)
    @address.secondary_contact = contacts(:jane_doe)
    @address.address_type = address_types(:family)
    assert_equal('The Doe Family', @address.addressee)
  end
  
  def test_addressee_with_unmarried_couple
    @address.primary_contact = contacts(:john_doe)
    @address.secondary_contact = contacts(:jane_doe)
    @address.address_type = address_types(:unmarried_couple)
    assert_equal('Mr. John Doe & Mrs. Jane Doe', @address.addressee)
  end

  def test_addressee_with_single_parent
    @address.primary_contact = contacts(:john_doe)
    @address.address_type = address_types(:single_parent)
    assert_equal('The Doe Family', @address.addressee)
  end
  
  def test_addressee_for_display_with_no_contacts
    assert_equal('123 Main St. Apt. 109, Chicago, IL 60606', @address.addressee_for_display)
  end
  
  def test_addressee_for_display_with_phone_only
    address = addresses(:phone_only)
    assert_equal('708-111-3333', address.addressee_for_display)
  end

  def test_addressee_for_display_with_individual
    @address.primary_contact = contacts(:john_doe)
    @address.address_type = address_types(:individual)
    assert_equal('Doe, Mr. John', @address.addressee_for_display)
  end

  def test_addressee_for_display_with_married_couple
    @address.primary_contact = contacts(:john_doe)
    @address.secondary_contact = contacts(:jane_doe)
    @address.address_type = address_types(:married_couple)
    assert_equal('Doe, Mr. & Mrs. John & Jane', @address.addressee_for_display)
  end
  
  def test_addressee_for_display_with_family
    @address.primary_contact = contacts(:john_doe)
    @address.secondary_contact = contacts(:jane_doe)
    @address.address_type = address_types(:family)
    assert_equal('Doe, Mr. & Mrs. John & Jane & Family', @address.addressee_for_display)
  end
  
  def test_addressee_for_display_with_unmarried_couple
    @address.primary_contact = contacts(:john_doe)
    @address.secondary_contact = contacts(:jane_doe)
    @address.address_type = address_types(:unmarried_couple)
    assert_equal('Doe, Mr. John Doe & Mrs. Jane', @address.addressee_for_display)
  end

  def test_addressee_for_display_with_single_parent
    @address.primary_contact = contacts(:john_doe)
    @address.address_type = address_types(:single_parent)
    assert_equal('Doe, Mr. John & Family', @address.addressee_for_display)
  end

  def test_find_for_list
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
    assert_equal(addresses(:phone_only), addresses[2])
    assert_equal(addresses(:tinley_park), addresses[3])
  end

  def test_find_all_eligible_for_group
    addresses = Address.find_all_eligible_for_group
    assert_equal(@num_address_fixtures - 1, addresses.size)
    assert(addresses.include?(addresses(:chicago)))
    assert(addresses.include?(addresses(:alsip)))
    assert(addresses.include?(addresses(:tinley_park)))

    assert(!addresses.include?(addresses(:phone_only)))
  end
  
  def test_unlink_contact_with_only_one_contact
    john = contacts(:john_doe)

    assert_equal(0, @address.contacts.size)
    john.address_id = @address.id; john.save; @address.contacts << john; @address.save; @address.link_contact
    assert_equal(1, @address.contacts.size)
    assert_equal(john.id, @address.contact1_id)

    john.address_id = nil; john.save
    @address.unlink_contact(john)

    assert_equal(0, @address.contacts.size)
  end

  def test_link_and_unlink_contact_where_secondary_moves_out
    setup_link_unlink_test

    # Jane moves out
    @jane.address_id = nil; @jane.save
    @address.unlink_contact(@jane)

    assert_equal(2, @address.contacts.size)
    assert_equal(@john.id, @address.contact1_id)
    assert_equal(@jimmy.id, @address.contact2_id)
  end
  
  def test_link_and_unlink_contact_where_primary_moves_out
    setup_link_unlink_test

    # John moves out
    @john.address_id = nil; @john.save
    @address.unlink_contact(@john)

    assert_equal(2, @address.contacts.size)
    assert_equal(@jimmy.id, @address.contact1_id)
    assert_equal(@jane.id, @address.contact2_id)
  end

  def test_link_and_unlink_contact_where_primary_and_secondary_move_out
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

  def test_delete_with_contacts_nullifies_contacts_address_id
    setup_link_unlink_test
    @address.destroy
    [@jimmy, @john, @jane].each { |contact| assert_nil(contact.address) }
  end

  def test_compare_with_no_primary_contacts
    chicago = addresses(:chicago)
    alsip = addresses(:alsip)
    assert_equal(0, chicago.compare_by_primary_contact(alsip))
  end

  def test_compare_with_one_primary_contact_on_each_side
    chicago = addresses(:chicago)
    alsip = addresses(:alsip)

    chicago.primary_contact = contacts(:john_doe)
    alsip.primary_contact = nil
    assert_equal(-1, chicago.compare_by_primary_contact(alsip))

    chicago.primary_contact = nil
    alsip.primary_contact = contacts(:john_doe)
    assert_equal(1, chicago.compare_by_primary_contact(alsip))
  end

  def test_compare_by_primary_contact
    chicago = addresses(:chicago)
    chicago.primary_contact = contacts(:john_doe)

    alsip = addresses(:alsip)
    alsip.primary_contact = contacts(:jane_doe)

    assert_equal(0, chicago.compare_by_primary_contact(chicago))
    assert_equal(-1, alsip.compare_by_primary_contact(chicago))
    assert_equal(1, chicago.compare_by_primary_contact(alsip))
  end

  def test_compare_with_non_address
    assert_raise ArgumentError do
      @address.compare_by_primary_contact("not an address")
    end
  end

  ##############################################################################
  private
  ##############################################################################

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

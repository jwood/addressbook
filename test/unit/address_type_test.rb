require File.dirname(__FILE__) + '/../test_helper'

class AddressTypeTest < ActiveSupport::TestCase
  fixtures :all

  test "should be able to get the type of an address_type" do
    assert_equal(address_types(:individual).get_type, :individual)
    assert_equal(address_types(:family).get_type, :family)
    assert_equal(address_types(:married_couple).get_type, :married_couple)
    assert_equal(address_types(:unmarried_couple).get_type, :unmarried_couple)
    assert_equal(address_types(:single_parent).get_type, :single_parent)
  end

  test "should be able to easily get the address type for an individual" do
    assert_equal(address_types(:individual), AddressType.individual)
  end
  
  test "should be able to easily get the address type for a family" do
    assert_equal(address_types(:family), AddressType.family)
  end

  test "should be able to determine if an address type only should have one main contact" do
    assert(address_types(:individual).only_one_main_contact?)
    assert(address_types(:single_parent).only_one_main_contact?)

    assert(!address_types(:family).only_one_main_contact?)
    assert(!address_types(:married_couple).only_one_main_contact?)
    assert(!address_types(:unmarried_couple).only_one_main_contact?)
  end

  test "should be able to determine the address types for an address with one contact" do
    contact = contacts(:john_doe)
    contact.assign_address(addresses(:chicago))
    contact.save

    address_types = AddressType.valid_address_types_for_address(addresses(:chicago)).map(&:get_type)
    assert address_types.include?(:individual)
    assert address_types.include?(:single_parent)
  end

  test "should be able to determine the address types for an address with multiple contacts" do
    contact = contacts(:john_doe)
    contact.assign_address(addresses(:chicago))
    contact.save

    contact = contacts(:jane_doe)
    contact.assign_address(addresses(:chicago))
    contact.save

    address_types = AddressType.valid_address_types_for_address(addresses(:chicago))
    assert_equal AddressType.all, address_types
  end

end

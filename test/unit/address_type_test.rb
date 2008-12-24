require File.dirname(__FILE__) + '/../test_helper'

class AddressTypeTest < Test::Unit::TestCase
  fixtures :address_types

  def test_get_type
    assert_equal(address_types(:individual).get_type, :individual)
    assert_equal(address_types(:family).get_type, :family)
    assert_equal(address_types(:married_couple).get_type, :married_couple)
    assert_equal(address_types(:unmarried_couple).get_type, :unmarried_couple)
    assert_equal(address_types(:single_parent).get_type, :single_parent)
  end
  
  def test_get_individual
    assert_equal(address_types(:individual), AddressType.individual)
  end
  
  def test_get_family
    assert_equal(address_types(:family), AddressType.family)
  end

  def test_only_one_primary_contact
    assert(address_types(:individual).only_one_main_contact?)
    assert(address_types(:single_parent).only_one_main_contact?)

    assert(!address_types(:family).only_one_main_contact?)
    assert(!address_types(:married_couple).only_one_main_contact?)
    assert(!address_types(:unmarried_couple).only_one_main_contact?)
  end
end

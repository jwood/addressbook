require File.dirname(__FILE__) + '/../test_helper'

class AddressTest < ActiveSupport::TestCase
  fixtures :all

  describe "An Address" do
    it "should not be created without all required info" do
      address = Address.new
      assert !address.valid?
      assert address.errors[:base].include?('You must specify a phone number or a full address')
    end

    it "should list the phone number as the addressee if there is no street address and no contacts" do
      address = addresses(:phone_only)
      assert_equal('708-111-3333', address.addressee)
    end

    it "should list the phone number as the addressee for display if there is only a phone number" do
      address = addresses(:phone_only)
      assert_equal('708-111-3333', address.addressee_for_display)
    end

    it "should be considered equal when sorted when they have no primary contacts" do
      chicago = addresses(:chicago)
      alsip = addresses(:alsip)
      assert_equal(0, chicago.compare_by_primary_contact(alsip))
    end

    it "should appear before addresses without primary contacts when sorted if they have a primary contact" do
      chicago = addresses(:chicago)
      alsip = addresses(:alsip)

      chicago.primary_contact = contacts(:john_doe)
      alsip.primary_contact = nil
      assert_equal(-1, chicago.compare_by_primary_contact(alsip))

      chicago.primary_contact = nil
      alsip.primary_contact = contacts(:john_doe)
      assert_equal(1, chicago.compare_by_primary_contact(alsip))
    end

    it "should be sorted by the name of their primary contact if both addresses have primary contacts" do
      chicago = addresses(:chicago)
      chicago.primary_contact = contacts(:john_doe)

      alsip = addresses(:alsip)
      alsip.primary_contact = contacts(:jane_doe)

      assert_equal(0, chicago.compare_by_primary_contact(chicago))
      assert_equal(-1, alsip.compare_by_primary_contact(chicago))
      assert_equal(1, chicago.compare_by_primary_contact(alsip))
    end

    it "should be considered empty if it has no information or only a home phone number" do
      assert Address.new.is_address_empty?
      assert Address.new(:home_phone => '312-555-1212').is_address_empty?
      assert !addresses(:alsip).is_address_empty?
    end

    it "should not be considered empty if it has no street address but a valid home phone" do
      assert Address.new.is_empty?
      assert !Address.new(:home_phone => '312-555-1212').is_empty?
      assert !addresses(:alsip).is_empty?
    end

    it "should be able to get the mailing address for an address" do
      assert_equal "123 Main St., Apt. 109, Chicago, IL 60606", addresses(:chicago).mailing_address
      assert_equal "456 Maple Ave., Alsip, IL 60803", addresses(:alsip).mailing_address
    end

    it "should be able to determine if one address is different from another" do
      assert addresses(:alsip).different_from?(addresses(:chicago))
      assert addresses(:alsip).different_from?(nil)
      assert addresses(:alsip).different_from?(Address.new)
      assert addresses(:alsip).different_from?(Address.new(addresses(:alsip).attributes.merge(:address2 => 'Apt 102')))

      assert !addresses(:alsip).different_from?(addresses(:alsip))
      assert !addresses(:alsip).different_from?(Address.new(addresses(:alsip).attributes.merge(:id => nil)))
    end

    it "should scrub the phone numbers before saving them to the database" do
      address = addresses(:alsip)
      address.home_phone = '(312) 555.1213'
      address.save!
      assert_equal '3125551213', address.home_phone
    end

    it "should be able to easily tell if an address only has one contact" do
      assign_contact_to_address(contacts(:john_doe), addresses(:chicago))
      assert addresses(:chicago).only_has_one_contact?

      assign_contact_to_address(contacts(:jane_doe), addresses(:chicago))
      assert !addresses(:chicago).only_has_one_contact?
    end

    it "should not be able to edit the address type of an address without the required primary and secondary contacts" do
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

    it "should fail validation with an invalid state code" do
      address = addresses(:chicago)
      address.state = "XY"
      assert !address.valid?
    end

    it "should fail validation with an invalid zip code" do
      address = addresses(:chicago)
      address.zip = "abcd"
      assert !address.valid?
    end

    it "should not consider partial addresses valid" do
      address = addresses(:chicago)
      address.city = ""
      assert !address.valid?
    end

    it "should be able to delete an address that is a member of a group" do
      address = addresses(:alsip)
      group = groups(:group_1)
      group.addresses = [address]
      group.save!

      assert group.addresses(true).include?(address)
      address.destroy
      assert !group.addresses(true).include?(address)
    end

    it "should not be able to update an address with an invalid phone number" do
      addresses(:chicago).home_phone = '(312) xxx-3333'
      assert !addresses(:chicago).valid?
      assert addresses(:chicago).errors[:home_phone].include?('is not valid')
    end

    it "should simply list the street address if it has no contacts" do
      assert_equal('123 Main St. Apt. 109, Chicago, IL 60606', addresses(:chicago).addressee)
    end

    it "should list the contact's name as the addressee for a single contact" do
      addresses(:chicago).primary_contact = contacts(:john_doe)
      addresses(:chicago).address_type = address_types(:individual)
      assert_equal('Mr. John Doe', addresses(:chicago).addressee)
    end

    it "should list both contacts names as the addressee for a married couple" do
      addresses(:chicago).primary_contact = contacts(:john_doe)
      addresses(:chicago).secondary_contact = contacts(:jane_doe)
      addresses(:chicago).address_type = address_types(:married_couple)
      assert_equal('Mr. & Mrs. John & Jane Doe', addresses(:chicago).addressee)
    end

    it "should list the family name as the addressee for a family" do
      addresses(:chicago).primary_contact = contacts(:john_doe)
      addresses(:chicago).secondary_contact = contacts(:jane_doe)
      addresses(:chicago).address_type = address_types(:family)
      assert_equal('The Doe Family', addresses(:chicago).addressee)
    end

    it "should list both contacts first and last names as the addressee if for an unmarried couple" do
      addresses(:chicago).primary_contact = contacts(:john_doe)
      addresses(:chicago).secondary_contact = contacts(:jane_doe)
      addresses(:chicago).address_type = address_types(:unmarried_couple)
      assert_equal('Mr. John Doe & Mrs. Jane Doe', addresses(:chicago).addressee)
    end

    it "should list the familiy name as the adressee if for a single parent" do
      addresses(:chicago).primary_contact = contacts(:john_doe)
      addresses(:chicago).address_type = address_types(:single_parent)
      assert_equal('The Doe Family', addresses(:chicago).addressee)
    end

    it "should list the street address as the addressee for display if it has no contacts" do
      assert_equal('123 Main St. Apt. 109, Chicago, IL 60606', addresses(:chicago).addressee_for_display)
    end

    it "should list that contact's name as the addressee for display for an individual" do
      addresses(:chicago).primary_contact = contacts(:john_doe)
      addresses(:chicago).address_type = address_types(:individual)
      assert_equal('Doe, Mr. John', addresses(:chicago).addressee_for_display)
    end

    it "should list both contacts as the addressee for display for a married couple" do
      addresses(:chicago).primary_contact = contacts(:john_doe)
      addresses(:chicago).secondary_contact = contacts(:jane_doe)
      addresses(:chicago).address_type = address_types(:married_couple)
      assert_equal('Doe, Mr. & Mrs. John & Jane', addresses(:chicago).addressee_for_display)
    end

    it "should list the primary contacts and family name as the addressee for display for a family" do
      addresses(:chicago).primary_contact = contacts(:john_doe)
      addresses(:chicago).secondary_contact = contacts(:jane_doe)
      addresses(:chicago).address_type = address_types(:family)
      assert_equal('Doe, Mr. & Mrs. John & Jane & Family', addresses(:chicago).addressee_for_display)
    end

    it "should list both contacts first and last names as the addressee for display for an unmarried couple" do
      addresses(:chicago).primary_contact = contacts(:john_doe)
      addresses(:chicago).secondary_contact = contacts(:jane_doe)
      addresses(:chicago).address_type = address_types(:unmarried_couple)
      assert_equal('Doe, Mr. John Doe & Mrs. Jane', addresses(:chicago).addressee_for_display)
    end

    it "should list the contact name and the family name in the addressee for display for a single parent" do
      addresses(:chicago).primary_contact = contacts(:john_doe)
      addresses(:chicago).address_type = address_types(:single_parent)
      assert_equal('Doe, Mr. John & Family', addresses(:chicago).addressee_for_display)
    end

    it "should not be able to compare an address with something that is not an Address" do
      assert_raise ArgumentError do
        addresses(:chicago).compare_by_primary_contact("not an address")
      end
    end

    it "should be able to find all addresses to list in the app" do
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

      addresses = Address.find([alsip.id, chicago.id, tinley_park.id, @phone_only.id])
      assert(tinley_park.in?(addresses))
      assert(chicago.in?(addresses))
      assert(@phone_only.in?(addresses))
      assert(alsip.in?(addresses))
    end

    it "should be able to find all addresses eligible to be a member in a group" do
      addresses = Address.eligible_for_group
      assert_equal(3, addresses.size)
      assert(addresses.include?(addresses(:chicago)))
      assert(addresses.include?(addresses(:alsip)))
      assert(addresses.include?(addresses(:tinley_park)))

      assert(!addresses.include?(addresses(:phone_only)))
    end

    it "should be able to unlink a contact from an address and delete the address if it only contains one contact" do
      john = contacts(:john_doe)

      assert_equal(0, addresses(:chicago).contacts.size)
      john.address_id = addresses(:chicago).id; john.save; addresses(:chicago).contacts << john; addresses(:chicago).save; addresses(:chicago).link_contact
      assert_equal(1, addresses(:chicago).contacts.size)
      assert_equal(john.id, addresses(:chicago).contact1_id)

      john.address_id = nil; john.save
      addresses(:chicago).unlink_contact(john)

      assert_nil Address.find_by_id(addresses(:chicago).id)
    end

    describe "with linked contacts" do
      before do
        @john = contacts(:john_doe)
        @jane = contacts(:jane_doe)
        @jimmy = contacts(:jimmy_doe)

        assert_equal(0, addresses(:chicago).contacts.size)

        [@john, @jane, @jimmy].each do |contact|
          contact.address_id = addresses(:chicago).id
          contact.save
          addresses(:chicago).contacts << contact
          addresses(:chicago).save!
          addresses(:chicago).link_contact
        end

        assert_equal(3, addresses(:chicago).contacts.size)
        assert_equal(@john.id, addresses(:chicago).contact1_id)
        assert_equal(@jane.id, addresses(:chicago).contact2_id)
      end

      it "should be able to unlink the secondary contact from an address, adjusting the main contacts accordingly" do
        # Jane moves out
        @jane.address_id = nil; @jane.save
        addresses(:chicago).unlink_contact(@jane)

        assert_equal(2, addresses(:chicago).contacts.size)
        assert_equal(@john.id, addresses(:chicago).contact1_id)
        assert_equal(@jimmy.id, addresses(:chicago).contact2_id)
      end

      it "should be able to unlink the primary contact from an address, adjusting the main contacts accordingly" do
        # John moves out
        @john.address_id = nil; @john.save
        addresses(:chicago).unlink_contact(@john)

        assert_equal(2, addresses(:chicago).contacts.size)
        assert_equal(@jimmy.id, addresses(:chicago).contact1_id)
        assert_equal(@jane.id, addresses(:chicago).contact2_id)
      end

      it "should be able to unlink the secondary and primary contacts from an address, adjusting the main contacts accordingly" do
        # John moves out
        @john.address_id = nil; @john.save
        addresses(:chicago).unlink_contact(@john)

        # Jane moves out
        @jane.address_id = nil; @jane.save
        addresses(:chicago).unlink_contact(@jane)

        assert_equal(1, addresses(:chicago).contacts.size)
        assert_equal(@jimmy.id, addresses(:chicago).contact1_id)
      end

      it "should nullify the contact's address id if an address is deleted" do
        addresses(:chicago).destroy
        [@jimmy, @john, @jane].each do |contact|
          contact.reload
          assert_nil(contact.address)
        end
      end
    end
  end

  private

    def assign_contact_to_address(contact, address)
      contact.assign_address(address)
      contact.save
    end

end

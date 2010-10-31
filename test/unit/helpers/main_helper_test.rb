require File.dirname(__FILE__) + '/../../test_helper'

class MainHelperTest < ActionView::TestCase

  context "The MainHelper class" do
    should "be able to break the contact list into chunks of contacts by the first letter in their last name" do
      albertson = Contact.new(:last_name => 'Albertson')
      barry = Contact.new(:last_name => 'Barry')
      dixon = Contact.new(:last_name => 'Dixon')
      donaldson = Contact.new(:last_name => 'donaldson')
      contact_list = [albertson, barry, dixon, donaldson]

      chunked_contacts = chunk_contact_list(contact_list)
      assert_equal 26, chunked_contacts.size

      # A
      assert_equal 1, chunked_contacts[0][1].size
      assert_equal albertson, chunked_contacts[0][1].first

      # B
      assert_equal 1, chunked_contacts[1][1].size
      assert_equal barry, chunked_contacts[1][1].first

      # C
      assert_equal 0, chunked_contacts[2][1].size

      # D
      assert_equal 2, chunked_contacts[3][1].size
      assert_equal dixon, chunked_contacts[3][1].first
      assert_equal donaldson, chunked_contacts[3][1].last
    end
  end

end

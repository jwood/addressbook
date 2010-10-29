require 'test_helper'

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

      assert_equal 1, chunked_contacts['A'].size
      assert_equal albertson, chunked_contacts['A'].first

      assert_equal 1, chunked_contacts['B'].size
      assert_equal barry, chunked_contacts['B'].first

      assert_equal 0, chunked_contacts['C'].size

      assert_equal 2, chunked_contacts['D'].size
      assert_equal dixon, chunked_contacts['D'].first
      assert_equal donaldson, chunked_contacts['D'].last
    end
  end

end

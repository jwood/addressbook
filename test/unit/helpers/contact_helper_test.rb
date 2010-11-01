require File.dirname(__FILE__) + '/../../test_helper'

class ContactHelperTest < ActionView::TestCase
  fixtures :all

  context "the ContactHelper" do
    should "be able to generate map and address links" do
      Settings.save_home_address(Address.new(:address1 => "123 South Ave", :city => "Chicago", :state => "IL", :zip => "60606"))
      contact = contacts(:john_doe)
      contact.update_attribute(:address, addresses(:alsip))
      assert_equal '<a href="http://maps.google.com/maps?q=456+Maple+Ave.,Alsip,IL+60803" target="new">Map</a> | <a href="http://maps.google.com/maps?daddr=456+Maple+Ave.,Alsip,IL+60803&saddr=123+South+Ave,Chicago,IL+60606" target="new">Directions</a>', add_map_and_directions_links(contact)
    end
  end

end

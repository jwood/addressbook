require 'test_helper'

class SettingsControllerTest < ActionController::TestCase

  test "should be able to get the home address" do
    Settings.save_home_address(Address.new(:address1 => "123 South Ave", :city => "Chicago", :state => "IL", :zip => "60606"))

    xhr :get, :address
    assert_equal "123 South Ave", assigns(:address).address1
    assert_equal "Chicago", assigns(:address).city
    assert_equal "IL", assigns(:address).state
    assert_equal "60606", assigns(:address).zip
  end

  test "should be able to update the home address" do
    Settings.save_home_address(Address.new(:address1 => "123 South Ave", :city => "Chicago", :state => "IL", :zip => "60606"))

    xhr :post, :address, :address => { :address1 => "555 North Ave", :city => "Tinley Park", :state => "IL", :zip => "60477" }
    assert_equal "555 North Ave", assigns(:address).address1
    assert_equal "Tinley Park", assigns(:address).city
    assert_equal "IL", assigns(:address).state
    assert_equal "60477", assigns(:address).zip    
  end

end

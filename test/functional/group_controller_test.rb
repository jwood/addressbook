require File.dirname(__FILE__) + '/../test_helper'

class GroupControllerTest < ActionController::TestCase
  fixtures :all
  
  def setup
    @eligible_for_group = [ addresses(:chicago), addresses(:tinley_park), addresses(:alsip) ]
  end

  test "should be able to get a blank form to create a new group" do
    xhr :get, :edit_group
    assert_template 'edit_group'
  end

  test "should be able to edit a group" do
    group = groups(:group_1)
    group.name = 'New Name'
    xhr :post, :edit_group, { :id => group.id, :group => group.attributes }
    assert_template 'edit_group'
    assert_equal(group.name, assigns(:group).name)
    assert_equal(true, assigns(:saved))
  end

  test "should be able to delete a group" do
    group = groups(:group_1)
    xhr :post, :delete_group, { :id => group.id }
    assert_template 'delete_group'
    assert_equal(group, assigns(:group))
  end

  test "should be able to modify the members of a group" do
    group = groups(:group_1)
    xhr :post, :edit_group, :included => [addresses(:chicago).id, addresses(:alsip).id], :id => group.id
    assert_template 'edit_group'
    assert assigns(:included).include?(addresses(:chicago))
    assert assigns(:included).include?(addresses(:alsip))
    assert assigns(:not_included).include?(addresses(:tinley_park))
  end

  test "should be able to create mailing lables for group members" do
    group = groups(:group_1)
    group.addresses << @eligible_for_group
    group.save

    get :create_labels, { :id => group.id, :label_type => 'Avery 8660' }
    assert_response :success
  end
  
end

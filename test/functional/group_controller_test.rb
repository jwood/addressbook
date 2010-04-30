require File.dirname(__FILE__) + '/../test_helper'

class GroupControllerTest < ActionController::TestCase
  fixtures :addresses, :groups
  
  def setup
    @eligible_for_group = [ addresses(:chicago), addresses(:tinley_park), addresses(:alsip) ]
  end

  def test_edit_group_get
    xhr :get, :edit_group
    assert_template 'edit_group'
  end

  def test_edit_group_post
    group = groups(:group_1)
    group.name = 'New Name'
    xhr :post, :edit_group, { :id => group.id, :group => group.attributes }
    assert_template 'edit_group'
    assert_equal(group.name, assigns(:group).name)
    assert_equal(true, assigns(:saved))
  end
  
  def test_delete_group
    group = groups(:group_1)
    xhr :post, :delete_group, { :id => group.id }
    assert_template 'delete_group'
    assert_equal(group, assigns(:group))
  end
  
  def test_modify_group_members
    group = groups(:group_1)
    xhr :post, :edit_group, :included => [addresses(:chicago).id, addresses(:alsip).id], :id => group.id
    assert_template 'edit_group'
    assert assigns(:included).include?(addresses(:chicago))
    assert assigns(:included).include?(addresses(:alsip))
    assert assigns(:not_included).include?(addresses(:tinley_park))
  end
  
  def test_create_labels
    group = groups(:group_1)
    group.addresses << @eligible_for_group
    group.save

    get :create_labels, { :id => group.id, :label_type => 'Avery 8660' }
    assert_response :redirect
    assert_redirected_to 'mailing_labels.pdf'
  end
  
end

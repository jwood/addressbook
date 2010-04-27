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
  
  def test_add_addresses_to_group
    group = groups(:group_1)
    xhr :post, :add_addresses_to_group, { :ids => [addresses(:chicago).id, addresses(:alsip).id], :group_id => group.id }
    assert_template 'update_address_group_lists'
    assert assigns(:included).include?(addresses(:chicago))
    assert assigns(:included).include?(addresses(:alsip))
    assert assigns(:not_included).include?(addresses(:tinley_park))
  end
  
  def test_remove_addresses_from_group
    group = groups(:group_1)
    xhr :post, :add_addresses_to_group, { :ids => [addresses(:chicago).id, addresses(:alsip).id], :group_id => group.id }
    assert assigns(:included).include?(addresses(:chicago))
    assert assigns(:included).include?(addresses(:alsip))

    xhr :post, :remove_addresses_from_group, { :ids => [addresses(:chicago).id, addresses(:alsip).id], :group_id => group.id }
    assert_template 'update_address_group_lists'
    assert !assigns(:included).include?(addresses(:chicago))
    assert !assigns(:included).include?(addresses(:alsip))
  end
  
  def test_add_all_addresses_to_group
    group = groups(:group_1)
    xhr :post, :add_all_addresses, { :id => group.id }

    assert_template 'update_address_group_lists'
    @eligible_for_group.each { |a| assert assigns(:included).include?(a) }
    assert_equal(0, assigns(:not_included).size)
    assert_equal(@eligible_for_group.size, assigns(:included).size)
  end
  
  def test_remove_all_address_from_group
    group = groups(:group_1)
    xhr :post, :add_all_addresses, { :id => group.id }
    @eligible_for_group.each { |a| assert assigns(:included).include?(a) }
    assert_equal(@eligible_for_group.size, assigns(:included).size)

    xhr :post, :remove_all_addresses, { :id => group.id }
    assert_equal(0, assigns(:included).size)
    @eligible_for_group.each { |a| assert assigns(:not_included).include?(a) }
    assert_equal(@eligible_for_group.size, assigns(:not_included).size)
  end

  def test_create_labels
    group = groups(:group_1)
    xhr :post, :add_all_addresses, { :id => group.id }
    assert_equal(@eligible_for_group.size, assigns(:included).size)

    get :create_labels, { :id => group.id, :label_type => 'Avery 8660' }
    assert_response :redirect
    assert_redirected_to 'mailing_labels.pdf'
  end
  
end

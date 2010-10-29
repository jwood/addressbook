require File.dirname(__FILE__) + '/../test_helper'

class GroupControllerTest < ActionController::TestCase
  fixtures :all
  
  context "on GET to :edit_group" do
    setup { xhr :get, :edit_group }

    should respond_with :success
    should render_template :edit_group
  end

  context "on POST to :edit_group" do
    setup do
      group = groups(:group_1)
      group.name = 'New Name'
      xhr :post, :edit_group, :id => group, :group => group.attributes
    end

    should respond_with :success
    should render_template :edit_group
    should("indicate the record was saved") { assert_equal true, assigns(:saved) }
    should("modify the group") { assert_equal 'New Name', assigns(:group).name }
  end

  context "on POST to delete_group" do
    setup do
      @group = groups(:group_1)
      xhr :post, :delete_group, :id => @group
    end

    should respond_with :success
    should render_template :delete_group
    should("return the group that was deleted") { assert_equal @group, assigns(:group) }
  end

  context "on POST to :edit_group to modify the members of a group" do
    setup do
      group = groups(:group_1)
      xhr :post, :edit_group, :id => group, :included => [addresses(:chicago).id, addresses(:alsip).id]
    end

    should respond_with :success
    should render_template :edit_group
    should "include the specified addresses" do
      assert assigns(:included).include?(addresses(:chicago))
      assert assigns(:included).include?(addresses(:alsip))
      assert assigns(:not_included).include?(addresses(:tinley_park))
    end
  end

  context "on GET to :create_labels" do
    setup do
      group = groups(:group_1)
      group.addresses << [ addresses(:chicago), addresses(:tinley_park), addresses(:alsip) ]
      group.save

      get :create_labels, :id => group, :label_type => 'Avery__8660'
    end

    should respond_with :success
  end
  
end

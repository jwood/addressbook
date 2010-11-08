require File.dirname(__FILE__) + '/../test_helper'

class GroupControllerTest < ActionController::TestCase
  fixtures :all
  
  context "on GET to :new" do
    setup { xhr :get, :new }

    should respond_with :success
    should render_template :edit_group
  end

  context "on POST to :create" do
    setup do
      xhr :post, :create, :group => { :name => 'Newly created group' }
    end

    should respond_with :success
    should render_template :edit_group
    should("indicate the record was saved") { assert_equal true, assigns(:saved) }
    should("create the group") { assert_equal 'Newly created group', assigns(:group).name }
  end

  context "on GET to :show" do
    setup { xhr :get, :show, :id => groups(:group_1) }

    should respond_with :success
    should render_template :edit_group
    should("return the specified group") { assert_equal groups(:group_1), assigns(:group) }
  end

  context "on GET to :edit" do
    setup { xhr :get, :edit, :id => groups(:group_1) }

    should respond_with :success
    should render_template :edit_group
    should("return the specified group") { assert_equal groups(:group_1), assigns(:group) }
  end

  context "on POST to :edit" do
    setup do
      group = groups(:group_1)
      group.name = 'New Name'
      xhr :post, :update, :id => group, :group => group.attributes
    end

    should respond_with :success
    should render_template :edit_group
    should("indicate the record was saved") { assert_equal true, assigns(:saved) }
    should("modify the group") { assert_equal 'New Name', assigns(:group).name }
  end

  context "on DELETE to destroy" do
    setup do
      @group = groups(:group_1)
      xhr :delete, :destroy, :id => @group
    end

    should respond_with :success
    should render_template :delete_group
    should("return the group that was deleted") { assert_equal @group, assigns(:group) }
  end

  context "on POST to :edit to modify the members of a group" do
    setup do
      group = groups(:group_1)
      xhr :post, :update, :id => group, :included => [addresses(:chicago).id, addresses(:alsip).id]
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

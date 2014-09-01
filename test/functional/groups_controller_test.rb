require File.dirname(__FILE__) + '/../test_helper'

class GroupsControllerTest < ActionController::TestCase
  tests GroupsController

  describe "on GET to :new" do
    before { xhr :get, :new }

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :edit_group }
  end

  describe "on POST to :create" do
    before do
      xhr :post, :create, :group => { :name => 'Newly created group' }
    end

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :edit_group }
    it("should indicate the record was saved") { assert_equal true, assigns(:saved) }
    it("should create the group") { assert_equal 'Newly created group', assigns(:group).name }
  end

  describe "on GET to :show" do
    before { xhr :get, :show, :id => groups(:group_1) }

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :edit_group }
    it("should return the specified group") { assert_equal groups(:group_1), assigns(:group) }
  end

  describe "on POST to :update" do
    before do
      group = groups(:group_1)
      group.name = 'New Name'
      xhr :post, :update, :id => group, :group => group.attributes
    end

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :edit_group }
    it("should indicate the record was saved") { assert_equal true, assigns(:saved) }
    it("should modify the group") { assert_equal 'New Name', assigns(:group).name }
  end

  describe "on DELETE to destroy" do
    before do
      @group = groups(:group_1)
      xhr :delete, :destroy, :id => @group
    end

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :delete_group }
    it("should return the group that was deleted") { assert_equal @group, assigns(:group) }
  end

  describe "on POST to :update to modify the members of a group" do
    before do
      group = groups(:group_1)
      xhr :post, :update, :id => group, :included => [addresses(:chicago).id, addresses(:alsip).id]
    end

    it("should respond with success") { assert_response :success }
    it("should render the proper template") { assert_template :edit_group }
    it "should include the specified addresses" do
      assert assigns(:included).include?(addresses(:chicago))
      assert assigns(:included).include?(addresses(:alsip))
      assert assigns(:not_included).include?(addresses(:tinley_park))
    end
  end

  describe "on GET to :create_labels" do
    before do
      group = groups(:group_1)
      group.addresses << [ addresses(:chicago), addresses(:tinley_park), addresses(:alsip) ]
      group.save

      get :create_labels, :id => group, :label_type => 'Avery8660'
    end

    it("should respond with success") { assert_response :success }
  end

end

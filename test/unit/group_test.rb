require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < ActiveSupport::TestCase
  fixtures :all

  test "should be able to find all groups for listing in the app" do
    groups = Group.find_for_list
    assert_equal(2, groups.size)
    assert_equal(groups(:group_1), groups[0])
    assert_equal(groups(:group_2), groups[1])
  end

end

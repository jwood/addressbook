require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < ActiveSupport::TestCase
  fixtures :groups

  def test_find_for_list
    groups = Group.find_for_list
    assert_equal(2, groups.size)
    assert_equal(groups(:group_1), groups[0])
    assert_equal(groups(:group_2), groups[1])
  end
end

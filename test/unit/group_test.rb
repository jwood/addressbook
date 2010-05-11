require File.dirname(__FILE__) + '/../test_helper'
require 'fileutils'

class GroupTest < ActiveSupport::TestCase
  fixtures :all

  test "should be able to find all groups for listing in the app" do
    groups = Group.find_for_list
    assert_equal(2, groups.size)
    assert_equal(groups(:group_1), groups[0])
    assert_equal(groups(:group_2), groups[1])
  end

  test "should be able to create mailing lables for group members" do
    group = groups(:group_1)
    group.addresses << [addresses(:chicago), addresses(:tinley_park), addresses(:alsip)]
    group.save

    label_file = File.join(Group::LABELS_PATH, Group::LABELS_FILE)
    FileUtils.rm_f label_file
    assert !File.exist?(label_file)
    group.create_labels('Avery 8660')
    assert File.exist?(label_file)
  end

  test "shoud be able to find all addresses eligible for group membership, but not in the group" do
    group = groups(:group_1)
    group.addresses = [addresses(:alsip)]
    group.save

    not_included = group.addresses_not_included
    assert_equal 2, not_included.size
    assert not_included.include?(addresses(:chicago))
    assert not_included.include?(addresses(:tinley_park))
  end

end

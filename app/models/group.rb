#------------------------------------------------------------------------------#
# This class represents a group of addresses
#------------------------------------------------------------------------------#
class Group < ActiveRecord::Base
  has_and_belongs_to_many :addresses

  #----------------------------------------------------------------------------#
  # Find the bunch of groups to be displayed in the group listing on the
  # main page.
  #----------------------------------------------------------------------------#
  def Group.find_for_list
    self.find(:all, :order => 'name')
  end    

end

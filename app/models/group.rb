class Group < ActiveRecord::Base
  has_and_belongs_to_many :addresses

  def self.find_for_list
    Group.find(:all, :order => 'name')
  end    

end

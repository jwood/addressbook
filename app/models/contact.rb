#------------------------------------------------------------------------------#
# This class represents a contact
#------------------------------------------------------------------------------#
class Contact < ActiveRecord::Base
  belongs_to :address

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :prefix
  validates_format_of :cell_phone, :with => /^\d\d\d-\d\d\d-\d\d\d\d$/, 
    :message => 'must be in the format of XXX-XXX-XXXX',
    :if => Proc.new { |contact| !contact.cell_phone.blank? }
  
  #----------------------------------------------------------------------------#
  # Remove this contact from the primary and secondary contact fields
  # of an address before it is destroyed.
  #----------------------------------------------------------------------------#
  def before_destroy
    self.address = nil
    save
    Address.remove_contact(self)
  end

  #----------------------------------------------------------------------------#
  # Find the bunch of contacts to be displayed in the contact listing on the
  # main page.
  #----------------------------------------------------------------------------#
  def Contact.find_for_list
    self.find(:all, :order => 'last_name, first_name')
  end    

end

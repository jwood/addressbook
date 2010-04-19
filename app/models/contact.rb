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

  named_scope :with_address, :conditions => 'address_id is not null'

  def before_destroy
    self.address = nil
    save
    Address.remove_contact(self)
  end

  def self.find_for_list
    self.find(:all, :order => 'last_name, first_name')
  end

  def full_name_last_first
    "#{last_name}, #{first_name}"
  end

  def has_address?
    !address.blank? && !address.is_empty?
  end

end

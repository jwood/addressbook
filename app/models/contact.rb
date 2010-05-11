class Contact < ActiveRecord::Base
  belongs_to :address

  before_save :sanitize_phone_numbers
  after_save :link_contact_to_address
  before_destroy :remove_contact_from_address

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :prefix
  validate :validate_phone_numbers

  named_scope :with_address, :conditions => 'address_id is not null'

  def self.find_for_list
    Contact.find(:all, :order => 'last_name, first_name')
  end

  def full_name_last_first
    "#{last_name}, #{first_name}"
  end

  def has_address?
    !address.blank? && !address.is_empty?
  end

  def assign_address(new_address)
    self.address.ergo.unlink_contact(self)
    self.address = new_address
  end

  private

    def link_contact_to_address
      address.ergo.link_contact
    end

    def sanitize_phone_numbers
      self.cell_phone = Phone.sanitize(self.cell_phone)
      self.work_phone = Phone.sanitize(self.work_phone)
    end

    def remove_contact_from_address
      self.address = nil
      save
      Address.remove_contact(self)
    end

    def validate_phone_numbers
      if !self.cell_phone.blank? && !Phone.valid?(self.cell_phone)
        errors.add(:cell_phone, "is not valid")
      end

      if !self.work_phone.blank? && !Phone.valid?(self.work_phone)
        errors.add(:work_phone, "is not valid")
      end
    end

end

class Address < ActiveRecord::Base

  has_and_belongs_to_many :groups
  has_many :contacts, :dependent => :nullify
  belongs_to :address_type
  belongs_to :primary_contact, :class_name => 'Contact', :foreign_key => "contact1_id"
  belongs_to :secondary_contact, :class_name => 'Contact', :foreign_key => "contact2_id"

  before_save :sanitize_phone_numbers

  validate :verify_required_info, :validate_phone_numbers, :verify_number_of_contacts_valid_for_address_type

  named_scope :eligible_for_group, :conditions => "address1 <> ''"
  
  def addressee_for_display
    no_contacts? ? format_address_with_no_contacts : address_type.format_address_for_display(self)
  end

  def addressee
    no_contacts? ? format_address_with_no_contacts : address_type.format_address_for_label(self)
  end

  def different_from?(other)
    if other.nil? || (address1 != other.address1 || address2 != other.address2 ||
                      city != other.city || state != other.state ||
                      zip != other.zip || home_phone != other.home_phone)
      true
    else
      false
    end
  end

  def mailing_address
    ma = address1
    ma << ", #{address2}" unless address2.blank?
    ma << ", #{city}, #{state} #{zip}"
  end

  def unlink_contact(contact)
    self.primary_contact = nil if self.primary_contact == contact
    self.secondary_contact = nil if self.secondary_contact == contact
    contacts.delete(contact)
    save
    contacts.size > 0 ? adjust_primary_secondary_contacts : self.destroy
  end

  def link_contact
    adjust_primary_secondary_contacts
  end

  def self.remove_contact(contact)
    addresses = Address.find(:all, :conditions => ['contact1_id = ? || contact2_id = ?', contact.id, contact.id])
    addresses.each { |a| a.unlink_contact(contact) }
  end

  def self.find_for_list
    address_list = Address.find(:all, :include => [:primary_contact, :secondary_contact, :address_type])
    address_list.sort! do |a1, a2|
      if a1.primary_contact.nil?
        result = 1
      elsif a2.primary_contact.nil?
        result = -1
      else
        result = a1.primary_contact.last_name <=> a2.primary_contact.last_name
        result = a1.primary_contact.first_name <=> a2.primary_contact.first_name if result == 0
      end
      result
    end
    address_list
  end

  def compare_by_primary_contact(other)
    raise ArgumentError unless other.class == self.class
    return -1 if other.nil?

    return -1 if !self.primary_contact.nil? &&  other.primary_contact.nil?
    return  1 if  self.primary_contact.nil? && !other.primary_contact.nil?
    return  0 if  self.primary_contact.nil? &&  other.primary_contact.nil?

    return "#{self.primary_contact.last_name}#{self.primary_contact.first_name}" <=>
      "#{other.primary_contact.last_name}#{other.primary_contact.first_name}"
  end

  def is_address_empty?
    id.blank? || address1.blank? || city.blank? || state.blank? || zip.blank?
  end

  def is_empty?
    is_address_empty? && home_phone.blank?
  end

  def only_has_one_contact?
    self.contacts(true).size == 1
  end

  private

    def sanitize_phone_numbers
      self.home_phone = Phone.sanitize(self.home_phone)
    end

    def validate_phone_numbers
      if !self.home_phone.blank? && !Phone.valid?(self.home_phone)
        errors.add(:home_phone, "is not valid")
      end
    end

    def verify_number_of_contacts_valid_for_address_type
      if contact2_id.nil? && self.address_type && !self.address_type.only_one_main_contact?
        errors.add_to_base("This address type requires primary and secondary contacts be specified")
      end
    end

    def adjust_primary_secondary_contacts
      # Get the first 2 contacts linked to this address
      primary_contacts = contacts.first(2)

      # Set contact1 to the first person in the contacts list if it is blank
      if self.primary_contact.blank? && primary_contacts[0]
        self.primary_contact = primary_contacts[0]
      elsif !primary_contacts[0]
        self.primary_contact = nil
      end

      # Set contact2 to the second person in the contacts list if it is blank
      if self.secondary_contact.blank? && primary_contacts[1]
        self.secondary_contact = primary_contacts[1]
      elsif !primary_contacts[1]
        self.secondary_contact = nil
      end

      # If contact1 == contact2, fix it
      if self.primary_contact == self.secondary_contact && self.primary_contact && self.secondary_contact
        if self.primary_contact == primary_contacts[0]
          self.primary_contact = primary_contacts[1]
        else
          self.primary_contact = primary_contacts[0]
        end
      end

      # Set the address type to individual if one contact, and family if there are two
      if !self.primary_contact.blank? && self.secondary_contact.blank?
        self.address_type = AddressType.individual
      elsif !self.primary_contact.blank? && !self.secondary_contact.blank?
        self.address_type = AddressType.family
      end

      save
    end

    def verify_required_info
      if home_phone.blank? && (address1.blank? || city.blank? || state.blank? || zip.blank?)
        errors.add_to_base("You must specify a phone number or a full address")
      end
    end

    def format_address_with_no_contacts
      if !address1.blank?
        addressee =  "#{address1}"
        addressee << " #{address2}" if !address2.blank?
        addressee << ", #{city}, #{state} #{zip}"
        return addressee
      else
        return home_phone
      end
    end

    def no_contacts?
      primary_contact.nil? && secondary_contact.nil?
    end

end

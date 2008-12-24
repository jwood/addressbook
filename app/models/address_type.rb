#------------------------------------------------------------------------------#
# This class represents an address type
#------------------------------------------------------------------------------#
class AddressType < ActiveRecord::Base
  has_one :address

  #----------------------------------------------------------------------------#
  # Get a symbol representing the address type, for easy comparison
  #----------------------------------------------------------------------------#
  def get_type
    return :individual if self.description == "Individual"
    return :family if self.description == "Family"
    return :married_couple if self.description == "Married Couple"
    return :unmarried_couple if self.description == "Unmarried Couple"
    return :single_parent if self.description == "Single Parent"
  end
  
  #----------------------------------------------------------------------------#
  # Accessors for specific address types
  #----------------------------------------------------------------------------#
  def AddressType.individual
    self.find_by_description("Individual")
  end

  def AddressType.family
    self.find_by_description("Family")
  end

  #----------------------------------------------------------------------------#
  # Format the address for display in the application
  #----------------------------------------------------------------------------#
  def format_address_for_display(address)
    if get_type == :family
      return "#{address.primary_contact.last_name}, #{address.primary_contact.prefix} & #{address.secondary_contact.prefix} #{address.primary_contact.first_name} & #{address.secondary_contact.first_name} & Family"
    elsif get_type == :individual
      return "#{address.primary_contact.last_name}, #{address.primary_contact.prefix} #{address.primary_contact.first_name}"
    elsif get_type == :married_couple
      return "#{address.primary_contact.last_name}, #{address.primary_contact.prefix} & #{address.secondary_contact.prefix} #{address.primary_contact.first_name} & #{address.secondary_contact.first_name}"
    elsif get_type == :unmarried_couple
      return "#{address.primary_contact.last_name}, #{address.primary_contact.prefix} #{address.primary_contact.first_name} #{address.primary_contact.last_name} & #{address.secondary_contact.prefix} #{address.secondary_contact.first_name}"
    elsif get_type == :single_parent
      return "#{address.primary_contact.last_name}, #{address.primary_contact.prefix} #{address.primary_contact.first_name} & Family"
    end
  end
  
  #----------------------------------------------------------------------------#
  # Format the address for display on a mailing label
  #----------------------------------------------------------------------------#
  def format_address_for_label(address)
    if get_type == :family
      return "The #{address.primary_contact.last_name} Family"
    elsif get_type == :individual
      return "#{address.primary_contact.prefix} #{address.primary_contact.first_name} #{address.primary_contact.last_name}"
    elsif get_type == :married_couple
      return "#{address.primary_contact.prefix} & #{address.secondary_contact.prefix} #{address.primary_contact.first_name} & #{address.secondary_contact.first_name} #{address.primary_contact.last_name}"
    elsif get_type == :unmarried_couple
      return "#{address.primary_contact.prefix} #{address.primary_contact.first_name} #{address.primary_contact.last_name} & #{address.secondary_contact.prefix} #{address.secondary_contact.first_name} #{address.secondary_contact.last_name}"
    elsif get_type == :single_parent
      return "The #{address.primary_contact.last_name} Family"
    end
  end

  #----------------------------------------------------------------------------#
  # Return true if tihs address type only has one main contact
  #----------------------------------------------------------------------------#
  def only_one_main_contact?
    if get_type == :individual || get_type == :single_parent
      return true
    else
      return false
    end
  end

end

class AddressType < ActiveRecord::Base
  has_one :address

  def get_type
    return :individual if description == 'Individual'
    return :family if description == 'Family'
    return :married_couple if description == 'Married Couple'
    return :unmarried_couple if description == 'Unmarried Couple'
    return :single_parent if description == 'Single Parent'
  end

  def self.individual
    AddressType.where("description = 'Individual'").first
  end

  def self.family
    AddressType.where("description = 'Family'").first
  end

  def format_address_for_display(address)
    if get_type == :family
      "#{address.primary_contact.last_name}, #{address.primary_contact.prefix} & #{address.secondary_contact.prefix} #{address.primary_contact.first_name} & #{address.secondary_contact.first_name} & Family"
    elsif get_type == :individual
      "#{address.primary_contact.last_name}, #{address.primary_contact.prefix} #{address.primary_contact.first_name}"
    elsif get_type == :married_couple
      "#{address.primary_contact.last_name}, #{address.primary_contact.prefix} & #{address.secondary_contact.prefix} #{address.primary_contact.first_name} & #{address.secondary_contact.first_name}"
    elsif get_type == :unmarried_couple
      "#{address.primary_contact.last_name}, #{address.primary_contact.prefix} #{address.primary_contact.first_name} #{address.primary_contact.last_name} & #{address.secondary_contact.prefix} #{address.secondary_contact.first_name}"
    elsif get_type == :single_parent
      "#{address.primary_contact.last_name}, #{address.primary_contact.prefix} #{address.primary_contact.first_name} & Family"
    end
  end

  def format_address_for_label(address)
    if get_type == :family
      "The #{address.primary_contact.last_name} Family"
    elsif get_type == :individual
      "#{address.primary_contact.prefix} #{address.primary_contact.first_name} #{address.primary_contact.last_name}"
    elsif get_type == :married_couple
      "#{address.primary_contact.prefix} & #{address.secondary_contact.ergo.prefix} #{address.primary_contact.first_name} & #{address.secondary_contact.ergo.first_name} #{address.primary_contact.last_name}"
    elsif get_type == :unmarried_couple
      "#{address.primary_contact.prefix} #{address.primary_contact.first_name} #{address.primary_contact.last_name} & #{address.secondary_contact.ergo.prefix} #{address.secondary_contact.ergo.first_name} #{address.secondary_contact.ergo.last_name}"
    elsif get_type == :single_parent
      "The #{address.primary_contact.last_name} Family"
    end
  end

  def only_one_main_contact?
    (get_type == :individual || get_type == :single_parent) ? true : false
  end

  def self.valid_address_types_for_address(address)
    if address.only_has_one_contact?
      AddressType.where("description = 'Individual' or description = 'Single Parent'")
    else
      AddressType.all
    end
  end

end

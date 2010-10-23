module AddressHelper

  def secondary_contact_style
    @address.address_type.ergo.only_one_main_contact? ? "display:none;" : ""
  end

end

module AddressHelper

  def secondary_contact_style
    if @address.address_type.ergo.only_one_main_contact?
      "display:none;"
    else
      ""
    end
  end

end

module AddressHelper

  def secondary_contact_style
    if @address.contact2_id.nil?
      "display:none;"
    else
      ""
    end
  end

end

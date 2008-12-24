#------------------------------------------------------------------------------#
# Helper methods for the address views
#------------------------------------------------------------------------------#
module AddressHelper

  #----------------------------------------------------------------------------#
  # If the specified condition is true, make the tr hidden
  #----------------------------------------------------------------------------#
  def hidden_tr_if(condition, attributes = {})
    attributes["style"] = "visibility:hidden;" if condition
    attrs = tag_options(attributes.stringify_keys)
    "<tr #{attrs}>"
  end
  
  #----------------------------------------------------------------------------#
  # Generate the drop down list containing the contacts linked to the address
  #----------------------------------------------------------------------------#
  def create_contact_dropdown(contact_num, address_contacts)
    select("address", "#{contact_num}_id", 
      address_contacts.collect {|c| [ "#{c.last_name}, #{c.first_name}", c.id ]}, {}, 
      :id => contact_num) 
  end
  
end

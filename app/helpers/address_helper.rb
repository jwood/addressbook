module AddressHelper

  def hidden_tr_if(condition, attributes = {})
    attributes["style"] = "display:none;" if condition
    attrs = tag_options(attributes.stringify_keys)
    "<tr #{attrs}>"
  end
  
  def create_contact_dropdown(contact_num)
    select("address", "#{contact_num}_id", 
      @address.contacts.collect {|c| [ "#{c.last_name}, #{c.first_name}", c.id ]}, {}, 
      :id => contact_num) 
  end
  
end

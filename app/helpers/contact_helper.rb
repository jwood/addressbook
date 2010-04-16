#------------------------------------------------------------------------------#
# Helper methods for the contact views
#------------------------------------------------------------------------------#
module ContactHelper
  require 'app_config'

  #----------------------------------------------------------------------------#
  # Add address modification links to the contact partial
  #----------------------------------------------------------------------------#
  def add_address_modification_links(contact)
    link_to_address_link = url_for(:action => :link_to_address, :id => contact)
    html =  "<a href=\"#\" onclick='openWindow(\"#{link_to_address_link}\", \"linkToAddressPopup\", \"width=750,height=300\");'>Link to Address</a>"
    html << ' | '
    html << link_to_remote("Create Address",
              :url => { :controller => 'address', :action => :edit_address },
              :method => 'get')

    unless contact.address.blank? 
      html << ' | '
      html << link_to_remote("Edit Address",
                :url => { :controller => 'address', :action => :edit_address, :id => contact.address },
                :method => 'get')
      html << ' | '
      html << link_to_remote("Unlink From Address",
                :url => { :action => :remove_address_from_contact, :id => contact },
                :confirm => "Are you sure you would like to unlink #{contact.first_name} #{contact.last_name} from their address?")
    end

    html
  end

  #----------------------------------------------------------------------------#
  # Add links to get map of contact's address and diretion's to contact's
  # address
  #----------------------------------------------------------------------------#
  def add_map_and_directions_links(contact)
    map_query = contact.address.address1 + ',' +
                contact.address.city + ',' +
                contact.address.state + ' ' +
                contact.address.zip
    map_query.gsub!(' ', '+')
    map_link = 'http://maps.google.com/maps?q=' + map_query
    html = "<a href=\"#{map_link}\" target=\"new\">Map</a>"

    user_address = AppConfig.user_address
    unless user_address.blank?
      directions_query = 'daddr=' +
        contact.address.address1 + ',' +
        contact.address.city + ',' +
        contact.address.state + ' ' +
        contact.address.zip
      directions_query += '&saddr=' +
        user_address[:address] + ',' +
        user_address[:city] + ',' +
        user_address[:state] + ' ' +
        user_address[:zip]
      directions_query.gsub!(' ', '+')
      directions_link = 'http://maps.google.com/maps?' + directions_query
      html += " | <a href=\"#{directions_link}\" target=\"new\">Directions</a>"
    end
    
    html
  end
  
end

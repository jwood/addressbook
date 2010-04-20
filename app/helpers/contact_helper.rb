#------------------------------------------------------------------------------#
# Helper methods for the contact views
#------------------------------------------------------------------------------#
module ContactHelper
  require 'app_config'

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

  def display_style_for_specify_address
    (@address.blank? || @address.is_empty?) ? "" : "display:none;"
  end
  
  def display_style_for_address
    @address.blank? ? "display:none;" : ""
  end

end

require 'app_config'

module ContactHelper

  def add_map_and_directions_links(contact)
    map_query = contact.address.address1 + ',' +
                contact.address.city + ',' +
                contact.address.state + ' ' +
                contact.address.zip
    map_query.gsub!(' ', '+')
    map_link = 'http://maps.google.com/maps?q=' + map_query
    html = "<a href=\"#{map_link}\" target=\"new\">Map</a>"

    user_address = AppConfig.user_address
    if !user_address.blank? && !is_mobile_device?
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

  def display_style_for_address
    (@address.blank? || @address.is_address_empty?) ? "display:none;" : ""
  end

  def display_style_for_specify_address
    (@address.blank? || @address.is_address_empty?) ? "" : "display:none;"
  end

  def has_contact_info_to_display?(contact)
    !contact.address.ergo.home_phone.ergo.blank? ||
            !contact.work_phone.blank? ||
            !contact.cell_phone.blank? ||
            !contact.email.blank? ||
            !contact.website.blank?
  end
  
end

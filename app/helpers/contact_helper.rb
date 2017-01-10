module ContactHelper

  def add_map_and_directions_links(contact)
    map_query = contact.address.address1 + ',' +
                contact.address.city + ',' +
                contact.address.state + ' ' +
                contact.address.zip
    map_query.gsub!(' ', '+')
    map_link = 'http://maps.google.com/maps?q=' + map_query
    html = "<a href=\"#{map_link}\" target=\"new\">Map</a>"

    user_address = Settings.home_address
    if !user_address.is_street_address_empty? && !mobile_device?
      directions_query = 'daddr=' +
        contact.address.address1 + ',' +
        contact.address.city + ',' +
        contact.address.state + ' ' +
        contact.address.zip
      directions_query += '&saddr=' +
        user_address.address1 + ',' +
        user_address.city + ',' +
        user_address.state + ' ' +
        user_address.zip
      directions_query.gsub!(' ', '+')
      directions_link = 'http://maps.google.com/maps?' + directions_query
      html += " | <a href=\"#{directions_link}\" target=\"new\">Directions</a>"
    end

    html.html_safe
  end

  def display_style_for_address(address)
    (address.blank? || address.is_address_empty?) ? "display:none;" : ""
  end

  def display_style_for_specify_address(address)
    (address.blank? || address.is_address_empty?) ? "" : "display:none;"
  end

  def has_contact_info_to_display?(contact)
    !contact.address.try(:home_phone).blank? ||
            !contact.work_phone.blank? ||
            !contact.cell_phone.blank? ||
            !contact.email.blank? ||
            !contact.website.blank?
  end

  private

  def mobile_device?
    respond_to?(:is_mobile_device?) && is_mobile_device?
  end

end

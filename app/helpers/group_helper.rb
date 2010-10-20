module GroupHelper

  def get_label_options(label_types)
    label_options = "" 
    label_types.each { |label_type| label_options << "<option value='#{label_type.gsub(' ', '_')}'>#{label_type}</option>" }
    label_options.html_safe
  end

  def options_for_group_members(group_members)
    html = ""
    group_members.each do |address|
      html << "<option value='#{address.id}' title='#{address.mailing_address}'>#{address.addressee_for_display}</option>"
    end
    html.html_safe
  end

end

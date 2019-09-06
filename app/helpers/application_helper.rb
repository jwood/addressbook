module ApplicationHelper
  def create_cancel_delete_links(object)
    unless object.id.blank?
      confirm = "Are you sure you would like to delete this entry?"
      if object.class == Address
        confirm = "Are you sure you would like to delete the address for #{object.addressee}?"
      elsif object.class == Contact
        confirm = "Are you sure you would like to delete #{object.first_name} #{object.last_name}?"
      elsif object.class == Group
        confirm = "Are you sure you would like to delete group #{object.name}?"
      end

      html = "<div class='buttons'>"
      html << button_to("Cancel", object, :method => :get, :remote => true, :class => 'ajax_request regular')
      html << button_to("Delete", object, :method => :delete, :remote => true, :data => { :confirm => confirm }, :class => 'ajax_request negative')
      html << "</div>"
      html.html_safe
    end
  end

  def create_id_for(object)
    obj_type = object.class.to_s.downcase
    "#{obj_type}_#{object.id}"
  end

  def create_link_to(object)
    if object.class == Contact
      link = "#{object.last_name}, #{object.first_name}"
    elsif object.class == Address
      link = "#{object.addressee_for_display}"
    elsif object.class == Group
      link = "#{object.name}"
    end

    html = '<li id="'
    html << create_id_for(object)
    html << '">'
    html << link_to(link, object, :method => :get, :remote => true, :class => 'ajax_request')
    html << '</li>'
    html.html_safe
  end

  def update_list(object, object_list, force=false)
    if (!object.nil? && !object.id.blank?) || force
      obj_type = object.class.to_s.downcase
      if !object_list.nil?
        "$('##{obj_type}List').html(\"#{j render(:partial => "main/#{obj_type}_list", :locals => {:object_list => object_list}) }\");"
      else
        "$('##{create_id_for(object)}').replaceWith('#{j create_link_to(object)}');"
      end
    end.try(:html_safe)
  end

  def remove_from_list(object)
    "$('##{create_id_for(object)}').replaceWith('');".html_safe
  end

  def highlight_in_list(object)
    "$('##{create_id_for(object)}').effect('highlight', {}, 2000);".html_safe
  end

  def phone_to(phone_number)
    link_to(Phone.format(phone_number), "tel:" + phone_number, :rel => 'external')
  end

  def put_or_post(object)
    object.try(:id).nil? ? :post : :put
  end

end

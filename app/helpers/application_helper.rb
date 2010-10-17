module ApplicationHelper

  def create_cancel_delete_links(object)
    obj_type = object.class.to_s.downcase
    unless object.id.blank?
      confirm = "Are you sure you would like to delete this entry?"
      if obj_type == 'address'
        confirm = "Are you sure you would like to delete the address for #{object.addressee}?"
      elsif obj_type == 'contact'
        confirm = "Are you sure you would like to delete #{object.first_name} #{object.last_name}?"
      elsif obj_type == 'group'
        confirm = "Are you sure you would like to delete group #{object.name}?"
      end

      html =  '<p>'
      html << link_to("Cancel", :remote => true,
                :url => { :action => "edit_#{obj_type}", :id => object },
                :method => 'get', :complete => "hideSpinner();", :loading => "showSpinner();")
      html << ' | '
      html << link_to("Delete", :remote => true,
                :url => { :action => "delete_#{obj_type}", :id => object },
                :confirm => confirm, :complete => "hideSpinner();", :loading => "showSpinner();")
      html << '</p>'
      html.html_safe
    end
  end

  def create_id_for(object)
    obj_type = object.class.to_s.downcase
    "#{obj_type}_#{object.id}"
  end

  def create_link_to(object)
    obj_type = object.class.to_s.downcase
    if obj_type == 'contact'
      link = "#{object.last_name}, #{object.first_name}"
    elsif obj_type == 'address' 
      link = "#{object.addressee_for_display}"
    elsif obj_type == 'group'
      link = "#{object.name}"
    end
  
    html = "<li id=\""
    html << create_id_for(object)
    html << "\">"
    html << link_to(link, url_for(:controller => obj_type, :action => "edit_#{obj_type}", :id => object),
        :method => :get, :remote => true, :class => 'ajax_link')
    html << "</li>"
    html.html_safe
  end
  
  def update_list(object, object_list, page, force=false)
    if (!object.nil? && !object.id.blank?) || force
      obj_type = object.class.to_s.downcase
      if !object_list.nil?
        #page.replace_html("#{obj_type}List", :partial => "main/#{obj_type}_list", :collection => object_list)
        page << "$('##{obj_type}List').html('#{escape_javascript(render :partial => "main/#{obj_type}_list", :collection => object_list)}')"
      else
        #page.replace(create_id_for(object), create_link_to(object))
        page << "$('##{create_id_for(object)}').replaceWith('#{escape_javascript(create_link_to(object))}')"
      end
    end
  end

  def remove_from_list(object, page)
    #page.replace(create_id_for(object), '')
    page << "$('##{create_id_for(object)}').replaceWith('')"
  end
  
  def highlight_in_list(object, page)
    page << "$('##{create_id_for(object)}').effect('highlight', {}, 2000);"
  end

  def phone_to(phone_number)
    link_to Phone.format(phone_number), "tel:" + phone_number
  end
  
end

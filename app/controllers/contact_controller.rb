class ContactController < ApplicationController

  def edit_contact
    render_target = 'edit_contact'
    @contact = Contact.find_by_id(params[:id]) || Contact.new

    if request.post?
      new_contact = true if params[:id].nil?
      @contact.attributes = params[:contact]

      new_address = parse_address
      if new_address && new_address.valid? && new_address.different_from(@contact.address)
        if @contact.address && @contact.address.contacts.size > 1
          session[:changed_address] = new_address
          render_target = 'edit_contact_with_shared_address'
        else
          if @contact.address.nil? || params[:address_specification_type] == 'existing_address'
            @contact.address.unlink_contact(@contact) unless @contact.address.nil?
            @contact.address = new_address
            new_address_saved = true
          else
            @contact.address.attributes = new_address.attributes
          end
        end
      end

      if @contact.errors.blank? && @contact.save
        @saved = true
      else
        logger.error("Edit contact failed: #{@contact.errors.full_messages}")
      end
    end

    @address = @contact.address || Address.new
    @contact_list = Contact.find_for_list if new_contact
    @address_list = Address.find_for_list if new_address_saved

    render :template => "contact/#{render_target}"
  end

  def change_address_for_contact
    @contact = Contact.find_by_id(params[:id])
    changed_address = session[:changed_address]

    if params[:submit_id] == 'yes'
      @contact.address.attributes = changed_address.attributes
      @contact.address.save if @contact.address.valid?
    else
      new_address = true
      @contact.address.unlink_contact(@contact) unless @contact.address.nil?
      @contact.address = changed_address
      @contact.save
    end

    @address = @contact.address || Address.new
    @address_list = Address.find_for_list if new_address
    render :template => 'contact/edit_contact'
  end
  
  def delete_contact
    @contact = Contact.find_by_id(params[:id])
    @contact.address.unlink_contact(@contact) unless @contact.address.nil?
    @old_address = Address.new
    @old_address.attributes = @contact.address.attributes unless @contact.address.nil?
    @contact.destroy if @contact
  end
  
  def remove_address_from_contact
    @contact = Contact.find_by_id(params[:id])
    @old_address_id = @contact.address_id
    @contact.address = nil

    if @contact.save
      @saved = true
      Address.find_by_id(@old_address_id).unlink_contact(@contact)
    else
      logger.error("Remove address to contact failed: #{@contact.errors.full_messages}")
    end

    render :template => 'contact/edit_contact'
  end

  def find_contact
    @contact_list = Contact.find(:all, 
      :conditions => ["last_name like ?", params[:last_name] << "%"],
      :order => 'last_name, first_name')
  end
  
  private

    def parse_address
      if params[:address_specification_type] == 'existing_address'
        other = Contact.find_by_id(params[:other_id])
        other.address
      elsif params[:address_specification_type] == 'specified_address'
        address = Address.new(params[:address])
        if address.valid?
          address
        else
          @contact.errors.add_to_base("Please specify a valid address")
          nil
        end
      end
    end
  
end

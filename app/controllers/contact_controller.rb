class ContactController < ApplicationController

  def edit_contact
    @contact = params[:id] && Contact.find_by_id(params[:id]) || Contact.new
    if request.post?
      new_contact = true if params[:id].nil?
      @contact.attributes = params[:contact]
      @contact.address = parse_address

      if @contact.errors.blank? && @contact.save
        @saved = true
      else
        logger.error("Edit contact failed: #{@contact.errors.full_messages}")
      end
    end
    @address = @contact.address || Address.new
    @contact_list = Contact.find_for_list if new_contact
    @address_list = Address.find_for_list if @new_address
  end
  
  def delete_contact
    @contact = Contact.find_by_id(params[:id])
    @contact.address.unlink_contact(@contact) unless @contact.address.nil?
    @old_address = Address.new
    @old_address.attributes = @contact.address.attributes unless @contact.address.nil?
    @contact.destroy if @contact
  end
  
  def add_address_to_contact
    @contact = Contact.find_by_id(params[:id])
    @contact.address.unlink_contact(@contact) unless @contact.address.blank?
    @contact.address = Address.find_by_id(params[:address_id]) 
    if @contact.save
      @saved = true
      @contact.address.link_contact
    else
      logger.error("Add address to contact failed: #{@contact.errors.full_messages}")
    end
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

    render :edit_contact do |page|
      page.redirect_to(:action => 'edit_contact', :id => @contact)
    end
  end

  def find_contact
    @contact_list = Contact.find(:all, 
      :conditions => ["last_name like ?", params[:last_name] << "%"],
      :order => 'last_name, first_name')
  end
  
  def link_to_address
    @contact = Contact.find_by_id(params[:id])
  end

  private

  def parse_address
    if params[:address_specification_type] == 'existing_address'
      other = Contact.find_by_id(params[:other_id])
      other.address
    elsif params[:address_specification_type] == 'specified_address'
      address = Address.new(params[:address])
      if address.valid?
        if @contact.address.nil?
          address.save
          @new_address = true
          address
        else
          @contact.address.attributes = address.attributes
          @contact.address.save
          @contact.address
        end
      else
        @contact.errors.add_to_base("Please specify a valid address")
        nil
      end
    end
  end
  
end

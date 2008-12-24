#------------------------------------------------------------------------------#
# This class serves up the actions that act on contacts.
#------------------------------------------------------------------------------#
class ContactController < ApplicationController

  #----------------------------------------------------------------------------#
  # Creates/Reads/Updates contacts.  When a new contact is created, the entire
  # contact list is handed back.
  #----------------------------------------------------------------------------#
  def edit_contact
    @contact = params[:id] && Contact.find_by_id(params[:id]) || Contact.new
    if request.post?
      new_contact = true if params[:id].nil?
      @contact.attributes = params[:contact]
      if @contact.save
        @saved = true
      else
        logger.error("Edit contact failed: #{@contact.errors.full_messages}")
      end
    end
    @contact_list = Contact.find_for_list if new_contact
  end
  
  #----------------------------------------------------------------------------#
  # Deletes a contact
  #----------------------------------------------------------------------------#
  def delete_contact
    @contact = Contact.find_by_id(params[:id])
    @contact.address.unlink_contact(@contact) unless @contact.address.nil?
    @old_address = Address.new
    @old_address.attributes = @contact.address.attributes unless @contact.address.nil?
    @contact.destroy if @contact
  end
  
  #----------------------------------------------------------------------------#
  # Add address info to a contact
  #----------------------------------------------------------------------------#
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
  
  #----------------------------------------------------------------------------#
  # Remove address info for a contact
  #----------------------------------------------------------------------------#
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
    redirect_to(:action => 'edit_contact', :id => @contact)
  end
  
  #----------------------------------------------------------------------------#
  # Find a contact by last name (full or partial)
  #----------------------------------------------------------------------------#
  def find_contact
    @contact_list = Contact.find(:all, 
      :conditions => ["last_name like ?", params[:last_name] << "%"],
      :order => 'last_name, first_name')
  end
  
  #----------------------------------------------------------------------------#
  # Get the form to link a contact to an address
  #----------------------------------------------------------------------------#
  def link_to_address
    @contact = Contact.find_by_id(params[:id])
  end    
  
end

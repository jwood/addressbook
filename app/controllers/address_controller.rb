#------------------------------------------------------------------------------#
# This class serves up the actions that act on addresses.
#------------------------------------------------------------------------------#
class AddressController < ApplicationController

  #----------------------------------------------------------------------------#
  # Creates/Reads/Updates addresses
  #----------------------------------------------------------------------------#
  def edit_address
    @address = params[:id] && Address.find_by_id(params[:id]) || Address.new
    @address_contacts = !@address.id.nil? && Contact.find_all_by_address_id(@address.id) || []
    if request.post?
      new_address = true if params[:id].nil?
      @address.attributes = params[:address]
      @address.secondary_contact = nil if @address.address_type.only_one_main_contact?
      if @address.save
        @saved = true
      else
        logger.error("Edit address failed: #{@address.errors.full_messages}")
      end
    end
    @address_list = Address.find_for_list if new_address
  end
  
  #----------------------------------------------------------------------------#
  # Deletes an address
  #----------------------------------------------------------------------------#
  def delete_address
    @address = Address.find_by_id(params[:id])
    @address.destroy if @address
  end
  
end

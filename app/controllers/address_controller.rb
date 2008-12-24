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
  
  #----------------------------------------------------------------------------#
  # Find an address by primary/secondary contact name or city
  #----------------------------------------------------------------------------#
  def find_address
    @contact = Contact.find_by_id(params[:id])
    @search_results = []
    
    # Search by primary and secondary contact last name
    addresses = Address.find(:all)
    unless params[:last_name].blank?
      addresses.each do |a|
        if (!a.primary_contact.nil? && a.primary_contact.last_name.downcase =~ /#{params[:last_name].downcase}/) ||
           (!a.secondary_contact.nil? && a.secondary_contact.last_name.downcase =~ /#{params[:last_name].downcase}/)
          @search_results << a
        end
      end
    end

    # Narrow by city
    unless params[:city].blank?
      if @search_results.empty?
        @search_results = Address.find_all_by_city(params[:city])
      else
        new_search_results = []
        @search_results.each { |sr| new_search_results << sr if sr.city.downcase == params[:city].downcase }
        @search_results = new_search_results
      end
    end

    # Narrow by home phone
    unless params[:home_phone].blank?
      if @search_results.empty?
        @search_results = Address.find_all_by_home_phone(params[:home_phone])
      else
        new_search_results = []
        @search_results.each { |sr| new_search_results << sr if sr.home_phone == params[:home_phone] }
        @search_results = new_search_results
      end
    end
  end

end

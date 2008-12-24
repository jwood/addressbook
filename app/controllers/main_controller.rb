#------------------------------------------------------------------------------#
# This class serves as the main controller to the application, serving up the 
# initial page that is chop full of javascript and other goodies.
#------------------------------------------------------------------------------#
class MainController < ApplicationController

  #----------------------------------------------------------------------------#
  # Builds the initial page
  #----------------------------------------------------------------------------#
  def index
    @group_list = Group.find_for_list
    @contact_list = Contact.find_for_list
    @address_list = Address.find_for_list
  end
  
end

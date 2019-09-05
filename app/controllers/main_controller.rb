class MainController < ApplicationController
  before_action :authenticate_user!

  def index
    @group_list = Group.find_for_list
    @contact_list = Contact.find_for_list
    @address_list = Address.find_for_list
  end

end

class AddressesController < ApplicationController

  def show
    @address = Address.find_by_id(params[:id])
    render 'edit_address'
  end

  def edit
    @address = Address.find_by_id(params[:id])
    render 'edit_address'
  end

  def update
    @address = Address.find_by_id(params[:id])
    @address.update_attributes(params[:address])
    @saved = @address.save
    render 'edit_address'
  end
  
  def destroy
    @address = Address.find_by_id(params[:id])
    @address.ergo.destroy
    render 'delete_address'
  end
  
end

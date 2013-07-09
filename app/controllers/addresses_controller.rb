class AddressesController < ApplicationController

  before_filter :load_address

  def show
    render 'edit_address'
  end

  def update
    @address.update_attributes(address_params)
    @saved = @address.save
    render 'edit_address'
  end

  def destroy
    @address.ergo.destroy
    render 'delete_address'
  end

  private

  def load_address
    @address = Address.find_by_id(params[:id])
  end

  def address_params
    params.require(:address).permit(:address1, :address2, :city, :state, :zip, :home_phone, :contact1_id, :contact2_id, :address_type_id)
  end

end

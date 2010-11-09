class AddressesController < ApplicationController

  before_filter :load_address

  def show
    render 'edit_address'
  end

  def update
    @address.update_attributes(params[:address])
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
  
end

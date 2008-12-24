class AddSingleParentType < ActiveRecord::Migration
  def self.up
    AddressType.create(:description => "Single Parent")
  end

  def self.down
    AddressType.destroy_all("description = 'Single Parent'")
  end
end

class CreateAddressTypes < ActiveRecord::Migration
  def self.up
    create_table :address_types do |t|
      t.column :description, :string
    end

    AddressType.create(:description => "Individual")
    AddressType.create(:description => "Family")
    AddressType.create(:description => "Married Couple")
    AddressType.create(:description => "Unmarried Couple")
    
    add_column :addresses, :address_type_id, :integer
  end

  def self.down
    drop_table :address_types
  end
end

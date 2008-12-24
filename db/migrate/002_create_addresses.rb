class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.column :address1, :string, :null => false
      t.column :address2, :string
      t.column :city, :string, :null => false
      t.column :state, :string, :null => false, :limit => 2
      t.column :zip, :string, :null => false
      t.column :home_phone, :string
      t.column :contact1_id, :integer
      t.column :contact2_id, :integer
    end
  end

  def self.down
    drop_table :addresses
  end
end

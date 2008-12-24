class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.column :prefix, :string
      t.column :first_name, :string, :null => false
      t.column :middle_name, :string
      t.column :last_name, :string, :null => false
      t.column :birthday, :date
      t.column :work_phone, :string
      t.column :cell_phone, :string
      t.column :email, :string
      t.column :website, :string
      t.column :address_id, :integer
    end
  end

  def self.down
    drop_table :contacts
  end
end

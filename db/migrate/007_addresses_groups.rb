class AddressesGroups < ActiveRecord::Migration
  def self.up
    create_table :addresses_groups, :id => false do |t|
      t.column :address_id, :integer
      t.column :group_id, :integer
    end
    
    execute "alter table addresses_groups add constraint fk_address foreign key (address_id) references addresses(id)"
    execute "alter table addresses_groups add constraint fk_groups foreign key (group_id) references groups(id)"   
  end

  def self.down
    drop_table :addresses_groups
  end
end

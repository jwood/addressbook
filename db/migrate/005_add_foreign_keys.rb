class AddForeignKeys < ActiveRecord::Migration
  def self.up
    # Contact
    execute "alter table contacts add constraint fk_contact_address foreign key (address_id) references addresses(id)"

    # Address
    execute "alter table addresses add constraint fk_address_contact1 foreign key (contact1_id) references contacts(id)"
    execute "alter table addresses add constraint fk_address_contact2 foreign key (contact2_id) references contacts(id)"
    execute "alter table addresses add constraint fk_address_address_type foreign key (address_type_id) references address_types(id)"
  end

  def self.down
  end
end

class AllowNullAddressInformation < ActiveRecord::Migration
  def self.up
    change_column_null :addresses, :address1, true
    change_column_null :addresses, :city, true
    change_column_null :addresses, :state, true
    change_column_null :addresses, :zip, true
  end

  def self.down
    change_column_null :addresses, :address1, false
    change_column_null :addresses, :city, false
    change_column_null :addresses, :state, false
    change_column_null :addresses, :zip, false
  end
end

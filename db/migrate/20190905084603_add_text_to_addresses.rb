class AddTextToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :text, :string
  end
end

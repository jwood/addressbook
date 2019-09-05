class AddUserToGroup < ActiveRecord::Migration
  def change
    add_reference :groups, :user, index: true, foreign_key: true
  end
end

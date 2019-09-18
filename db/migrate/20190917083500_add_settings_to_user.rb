class AddSettingsToUser < ActiveRecord::Migration
  def change
    add_column :users, :settings, :jsonb
  end
end

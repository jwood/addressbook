class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.text :tag
      t.text :icon

      t.timestamps null: false
    end
  end
end

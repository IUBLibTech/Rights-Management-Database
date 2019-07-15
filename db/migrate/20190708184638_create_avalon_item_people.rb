class CreateAvalonItemPeople < ActiveRecord::Migration
  def change
    create_table :avalon_item_people do |t|
      t.integer :person_id, limit: 8
      t.integer :avalon_item_id, limit: 8
      t.timestamps null: false
    end
  end
end

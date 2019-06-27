class CreateAvalonItems < ActiveRecord::Migration
  def change
    create_table :avalon_items do |t|
      t.string :avalon_id, null: false
      t.string :title, null: false
      t.text :json, null: false
      t.string :pod_unit, null: false

      t.timestamps null: false
    end
    add_index :avalon_items, :avalon_id, unique: true
  end
end

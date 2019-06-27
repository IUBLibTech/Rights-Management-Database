class AddAvalonItemIdToRecording < ActiveRecord::Migration
  def change
    add_column :recordings, :avalon_item_id, :integer, limit: 8

    add_index :recordings, :avalon_item_id
  end
end

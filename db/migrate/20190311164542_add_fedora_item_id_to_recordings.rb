class AddFedoraItemIdToRecordings < ActiveRecord::Migration
  def change
    add_column :recordings, :fedora_item_id, :string
  end
end

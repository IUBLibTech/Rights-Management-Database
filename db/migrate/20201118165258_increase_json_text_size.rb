class IncreaseJsonTextSize < ActiveRecord::Migration
  def up
    change_column :avalon_items, :json, :text, limit: 16.megabytes - 1
  end

  def down
    change_column :avalon_items, :json, :text, limit: 64.kilobytes - 1
  end
end

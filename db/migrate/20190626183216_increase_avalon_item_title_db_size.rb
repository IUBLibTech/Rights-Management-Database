class IncreaseAvalonItemTitleDbSize < ActiveRecord::Migration
  def change
    change_column :avalon_items, :title, :text
  end
end

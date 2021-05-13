class AddCollectionToAvalonItem < ActiveRecord::Migration
  def change
    add_column :avalon_items, :collection, :text
  end
end

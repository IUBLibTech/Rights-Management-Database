class RemoveAccessDeterminationFromAvalonItem < ActiveRecord::Migration
  def change
    remove_column :avalon_items, :access_determination
  end
end

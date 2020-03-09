class AddCurrentAccessDecisionToAvalonItem < ActiveRecord::Migration
  def change
    add_column :avalon_items, :current_access_determination_id, :integer, limit: 8
  end
end

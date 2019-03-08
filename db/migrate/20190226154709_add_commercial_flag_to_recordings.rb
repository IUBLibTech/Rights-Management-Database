class AddCommercialFlagToRecordings < ActiveRecord::Migration
  def change
    add_column :recordings, :commercial, :boolean
  end
end

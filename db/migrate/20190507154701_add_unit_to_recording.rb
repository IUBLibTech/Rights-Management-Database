class AddUnitToRecording < ActiveRecord::Migration
  def change
    add_column :recordings, :unit, :string, null: false
  end
end

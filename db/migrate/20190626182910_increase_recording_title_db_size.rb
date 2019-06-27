class IncreaseRecordingTitleDbSize < ActiveRecord::Migration
  def change
    change_column :recordings, :title, :text
  end
end

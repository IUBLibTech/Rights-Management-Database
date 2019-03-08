class CreateRecordingTakeDownNotices < ActiveRecord::Migration
  def change
    create_table :recording_take_down_notices do |t|
      add_column :recording_id, :integer, limit: 8
      add_column :take_down_notice_id, :integer, limit: 8
      t.timestamps null: false
    end
  end
end

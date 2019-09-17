class CreateTracks < ActiveRecord::Migration[5.0]
  def change
    create_table :tracks do |t|
      t.integer :performance_id, limit: 8, null: false
      t.integer :recording_start_time
      t.timestamps
    end
  end
end

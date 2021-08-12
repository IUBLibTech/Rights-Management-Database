class CreateTrackWorks < ActiveRecord::Migration
  def change
    create_table :track_works do |t|
      t.integer :track_id, limit: 8
      t.integer :work_id, limit: 8
      t.timestamps null: false
    end
  end
end

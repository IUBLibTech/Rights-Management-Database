class AddAtomFeedReadToRecording < ActiveRecord::Migration
  def change
    add_column :recordings, :atom_feed_read_id, :integer, limit: 8
  end
end

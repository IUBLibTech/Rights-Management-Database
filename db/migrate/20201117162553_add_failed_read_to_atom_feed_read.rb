class AddFailedReadToAtomFeedRead < ActiveRecord::Migration
  def change
    add_column :atom_feed_reads, :json_failed, :boolean, default: false
    add_column :atom_feed_reads, :json_error_message, :text
    AtomFeedRead.update_all json_failed: false
  end
end

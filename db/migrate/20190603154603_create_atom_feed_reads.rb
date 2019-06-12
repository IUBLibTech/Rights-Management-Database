class CreateAtomFeedReads < ActiveRecord::Migration
  def change
    create_table :atom_feed_reads do |t|
      t.text :title, null: false
      t.datetime :avalon_last_updated, null: false
      t.string :json_url, null: false
      t.string :avalon_id, null: false
      t.boolean :successfully_read, default: false
      t.text :json
      t.timestamps null: false

      t.index :avalon_id, unique: true
    end
  end
end

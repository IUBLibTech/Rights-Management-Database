class AddEntryXmlToAtomFeedRead < ActiveRecord::Migration
  def change
    add_column :atom_feed_reads, :entry_xml, :text
  end
end

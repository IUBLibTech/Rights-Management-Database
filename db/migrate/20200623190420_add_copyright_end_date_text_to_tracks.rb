class AddCopyrightEndDateTextToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :copyright_end_date_text, :string
  end
end

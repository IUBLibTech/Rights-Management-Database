class AddLastUpdatedByToRecording < ActiveRecord::Migration
  def change
    add_column :recordings, :last_updated_by, :string
  end
end

class SetDefaultAccessDetermination < ActiveRecord::Migration
  def up
    Recording.update_all(access_determination: Recording::DEFAULT_ACCESS)
  end

  def down
    # prior to this migration, all values were nil
    Recording.update_all(access_determination: nil)
  end
end

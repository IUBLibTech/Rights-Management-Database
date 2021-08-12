class AddRolesToTrackContributorPeople < ActiveRecord::Migration
  def change
    add_column :track_contributor_people, :contributor, :boolean
    add_column :track_contributor_people, :principle_creator, :boolean
  end
end

class AddRolesToPerformanceContributorPeople < ActiveRecord::Migration
  def change
    add_column :performance_contributor_people, :interviewer, :boolean
    add_column :performance_contributor_people, :performer, :boolean
    add_column :performance_contributor_people, :conductor, :boolean
    add_column :performance_contributor_people, :interviewee, :boolean
  end
end

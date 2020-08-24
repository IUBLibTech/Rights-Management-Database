class AddRolesToWorkContributorPerson < ActiveRecord::Migration
  def change
    add_column :work_contributor_people, :principle_creator, :boolean
    add_column :work_contributor_people, :contributor, :boolean
  end
end

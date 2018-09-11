class Work < ActiveRecord::Base
  has_many :performances
  has_many :work_contributor_people
  has_many :people, through: :work_contributor_people

  alias_attribute :work_contributors, :people
end

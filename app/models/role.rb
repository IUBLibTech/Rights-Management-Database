class Role < ApplicationRecord
  has_many :people, through: :work_contributor_people
  has_many :works, through: :work_contributor_people
  has_many :performance_contributors
  has_many :people, as: :performers
end

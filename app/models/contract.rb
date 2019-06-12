class Contract < ActiveRecord::Base
  has_many :performance_contributor_people
  has_many :people, through: :performance_contributor_people
end

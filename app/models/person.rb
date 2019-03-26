class Person < ActiveRecord::Base
  has_many :person_nationalities
  has_many :nationalities, through: :person_nationalities
  has_many :work_contributor_people
  has_many :works, through: :work_contributor_people
  has_many :people_iu_affiliations
  has_many :iu_affiliations, through: :people_iu_affiliations
  has_many :performance_contributors

end

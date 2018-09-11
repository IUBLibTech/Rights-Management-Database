class Nationality < ActiveRecord::Base
  has_many :person_nationalities
  has_many :persons, through: :person_nationalities
end

class PersonIuAffiliation < ActiveRecord::Base
  belongs_to :person
  belongs_to :iu_affiliation
end

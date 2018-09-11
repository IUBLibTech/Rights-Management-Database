class IuAffiliation < ActiveRecord::Base
  has_many :person_iu_affiliates
  has_many :persons, through :person_iu_affiliates
end

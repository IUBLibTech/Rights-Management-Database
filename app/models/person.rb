class Person < ActiveRecord::Base
  before_save :convert_edtf
  has_many :person_nationalities
  has_many :nationalities, through: :person_nationalities
  has_many :work_contributor_people
  has_many :works, through: :work_contributor_people
  has_many :person_iu_affiliations
  has_many :iu_affiliations, through: :person_iu_affiliations
  has_many :performance_contributor_people

  def name
    "#{first_name} #{last_name}"
  end

  # This method ensures that when an EDTF text date is modified (added, changed or removed), that the underlying
  # DB Date reflects that
  def convert_edtf
    self.date_of_birth = date_of_birth_edtf.blank? ? nil : Date.edtf(date_of_birth_edtf)
    self.date_of_death = date_of_death_edtf.blank? ? nil : Date.edtf(date_of_death_edtf)
  end


end

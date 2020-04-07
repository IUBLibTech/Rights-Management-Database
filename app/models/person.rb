class Person < ActiveRecord::Base
  before_save :convert_edtf
  has_many :person_nationalities
  has_many :nationalities, through: :person_nationalities

  has_many :person_iu_affiliations
  has_many :iu_affiliations, through: :person_iu_affiliations

  has_many :recording_contributor_people
  has_many :recordings, through: :recording_contributor_people

  has_many :performance_contributor_people
  has_many :performances, through: :performance_contributor_people

  has_many :track_contributor_people
  has_many :tracks, through: :track_contributor_people

  has_many :work_contributor_people
  has_many :works, through: :work_contributor_people


  RECORDING_CONTRIBUTOR_ROLES_KEY = "recording"
  PERFORMANCE_CONTRIBUTOR_ROLES_KEY = "performance"
  WORK_CONTRIBUTOR_ROLES_KEY = "work"
  ROLES = {
      RECORDING_CONTRIBUTOR_ROLES_KEY => ["Depositor (R)", "Recording Producer (R)"],
      PERFORMANCE_CONTRIBUTOR_ROLES_KEY => ["Interviewer (P)", "Performer (P)", "Conductor (P)", "Interviewee (P)"],
      WORK_CONTRIBUTOR_ROLES_KEY => ["Contributor (W)", "Principle Creator (W)"]
  }
  ALL_ROLES = Person::ROLES.keys.collect{|k| Person::ROLES[k]}.flatten.sort

  def name
    "#{first_name} #{last_name}"
  end
  def full_name
    "#{first_name} #{middle_name} #{last_name}"
  end

  # This method ensures that when an EDTF text date is modified (added, changed or removed), that the underlying
  # DB Date reflects that
  def convert_edtf
    self.date_of_birth = date_of_birth_edtf.blank? ? nil : Date.edtf(date_of_birth_edtf)
    self.date_of_death = date_of_death_edtf.blank? ? nil : Date.edtf(date_of_death_edtf)
  end


end

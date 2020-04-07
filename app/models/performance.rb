class Performance < ActiveRecord::Base
  has_many :recording_performances
  has_many :recordings, through: :recording_performances
  has_many :tracks, dependent: :delete_all
  has_many :performance_notes
  has_many :performance_contributor_people
  has_many :people, through: :performance_contributor_people

  accepts_nested_attributes_for :tracks
  #before_save :normalize_date

  def normalize_date
    self.performance_date = Date.strptime(self.performance_date_string, "%m/%d/%Y")
  end

end

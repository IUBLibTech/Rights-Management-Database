class Performance < ActiveRecord::Base
  validates :work_id, uniqueness: {scope: [:id]}
  has_many :recording_performances
  has_many :recordings, through: :recording_performances
  belongs_to :work
  has_many :performance_contributor_people
  has_many :people, through: :performance_contributor_people
end

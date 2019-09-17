class Performance < ActiveRecord::Base
  has_many :recording_performances
  has_many :recordings, through: :recording_performances
  has_many :tracks

end

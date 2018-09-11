class Recording < ActiveRecord::Base
  has_many :recording_performances
  has_many :performances, through: :recording_performances
end

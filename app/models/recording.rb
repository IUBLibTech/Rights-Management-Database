class Recording < ActiveRecord::Base
  # has_many :recording_performances
  # has_many :performances, through: :recording_performances

  DEFAULT_ACCESS = "Default IU Access - Not Reviewed"
  IU_ACCESS = "IU Access - Reviewed"
  WORLD_WIDE_ACCESS = "World Wide Access"
  RESTRICTED_ACCESS = "Restricted Access"
  ACCESS_DECISIONS = [DEFAULT_ACCESS, IU_ACCESS, WORLD_WIDE_ACCESS, RESTRICTED_ACCESS]
  validates :access_determination, :inclusion => {:in => ACCESS_DECISIONS}



end

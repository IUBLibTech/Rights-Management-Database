class Recording < ActiveRecord::Base
  # has_many :recording_performances
  # has_many :performances, through: :recording_performances

  has_many :past_access_decisions

  DEFAULT_ACCESS = "Default IU Access - Not Reviewed"
  IU_ACCESS = "IU Access - Reviewed"
  WORLD_WIDE_ACCESS = "World Wide Access"
  RESTRICTED_ACCESS = "Restricted Access"
  ACCESS_DECISIONS = [DEFAULT_ACCESS, IU_ACCESS, WORLD_WIDE_ACCESS, RESTRICTED_ACCESS]
  validates :access_determination, :inclusion => {:in => ACCESS_DECISIONS}
  validates_each :mdpi_barcode, allow_blank: false do |record, attr, value|

  end
  after_update :record_access_change

  def record_access_change
    PastAccessDecision.new(recording_id: self.id, decision: self.access_determination, changed_by: User.current_username).save! if access_determination_changed?
  end

  def valid_barcode

  end

end

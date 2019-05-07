class RecordingTakeDownNotice < ActiveRecord::Base
  belongs_to :recording
  belongs_to :take_down_notice
end

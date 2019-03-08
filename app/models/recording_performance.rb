class RecordingPerformance < ActiveRecord::Base
  belongs_to :recording
  belongs_to :performance
end

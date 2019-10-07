class RecordingPerformance < ActiveRecord::Base
  belongs_to :recording
  belongs_to :performance
  accepts_nested_attributes_for :performance
end

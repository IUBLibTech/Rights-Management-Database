class Track < ActiveRecord::Base
  belongs_to :performance
  has_many :track_works
  has_many :works, through: :track_works
  has_many :track_contributor_people
  has_many :contributors, -> { where "interviewer = true OR interviewee = true OR conductor = true OR performer = true" }, class_name: "TrackContributorPerson"
  has_many :people, through: :contributors

  # recording_start_time is input as hh:mm:ss but stored as seconds
  def recording_start_time=(time)
    if time.blank?
      super(nil)
    else
      super(time.split(':').map { |a| a.to_i }.inject(0) { |a, b| a * 60 + b})
    end
  end

  def recording_start_time
    unless super.nil?
      hh_mm_sec(super)
    end
  end

  def recording_end_time=(time)
    if time.blank?
      super(nil)
    else
      super(time.split(':').map { |a| a.to_i }.inject(0) { |a, b| a * 60 + b})
    end
  end

  def recording_end_time
    unless super.nil?
      hh_mm_sec(super)
    end
  end

  def hh_mm_sec(totalSeconds)
    hh = (totalSeconds / 3600).floor
    mm = ((totalSeconds - (hh * 3600)) / 60).floor
    ss = totalSeconds - (hh * 3600) - (mm * 60)
    "#{hh}:#{"%02d" % mm}:#{"%02d" % ss}"
  end
end

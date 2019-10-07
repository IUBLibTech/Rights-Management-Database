class Track < ActiveRecord::Base
  belongs_to :performance

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

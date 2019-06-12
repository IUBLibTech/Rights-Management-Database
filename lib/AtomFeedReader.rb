require 'singleton'

class AtoFeedReader
  include Singleton

  # Automated run between 11pm and midnight each night
  WINDOW_START = 23 * 60 # 11pm, in minutes
  WINDOW_STOP = 24 * 60 # midnight, in minutes

  @@thread ||= nil

  def aa_logger
    @@aa_logger ||= Logger.new("#{Rails.root}/log/auto_accept.log")
  end

  def thread_active?
    @@thread ? true : false
  end

  def start

  end

  def stop

  end


end
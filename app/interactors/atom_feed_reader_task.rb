class AtomFeedReaderTask
  include Delayed::RecurringJob
  include AfrHelper

  timezone 'US/Eastern'
  run_every 10.seconds
  run_at Time.now
  queue 'feed-reader'

  def perform
    # see AfrHelper for this
    read_atom_feed
  end


end
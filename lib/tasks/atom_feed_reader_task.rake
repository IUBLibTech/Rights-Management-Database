desc 'Runs the background process that reads the Avalon atom feed'
task read_feed: :environment do
  AtomFeedReaderTask.schedule!
end

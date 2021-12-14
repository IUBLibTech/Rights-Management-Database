namespace :avalon do
  desc 'Runs the background process that reads the Avalon atom feed'
  task read_atom_feed: :environment do
    # these are no longer called as rake tasks. they've been added to config/initializers/delayed_job_config.rb
    # This will only work when there is a single instance of RMD running
    #AtomFeedReaderTask.schedule!
  end

  desc 'Runs the background process that parses JSON records in MCO'
  task parse_json: :environment do
    # these are no longer called as rake tasks. they've been added to config/initializers/delayed_job_config.rb
    # This will only work when there is a single instance of RMD running
    #JsonReaderTask.schedule!
  end
end

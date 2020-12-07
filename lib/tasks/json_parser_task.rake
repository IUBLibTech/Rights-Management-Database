desc 'Runs the background process that parses JSON records in MCO'
task parse_json: :environment do
  JsonReaderTask.schedule!
end
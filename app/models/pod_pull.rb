class PodPull < ActiveRecord::Base

  def self.pull_pod_records(ts)
    ts ||= PodPull.last_pull_timestamp

    # grab the current time one the POD database
    new_ts = PodPhysicalObject.connection.execute('select now()').first[0]
    puts "POD db time: #{new_ts}"
    Recording.transaction do
      if ts.nil?
        pos = PodPhysicalObject.joins(:pod_digital_statuses).where('digital_statuses.state = "archived"')
      else
        pos = PodPhysicalObject.joins(:pod_digital_statuses).where("digital_statuses.state='archived' AND digital_statuses.created_at >= '#{ts}'")
      end
      create_rmd_recordings(pos)
      PodPull.new(pull_timestamp: new_ts).save!
    end
  end

  def self.last_pull_timestamp
    PodPull.last&.pull_timestamp
  end

  def self.get_physical_objects(ts)
    PodPhysicalObject.joins(:pod_digital_statuses).where("digital_statuses.state='archived' AND digital_statuses.created_at > '#{ts}'")
  end

  private
  def self.create_rmd_recordings(pod_physical_objects)
    pod_physical_objects.each_with_index do |p, i|
      puts "#{i} of #{pod_physical_objects.size}: #{p.mdpi_barcode}"
      Recording.new(mdpi_barcode: p.mdpi_barcode, title: p.title, format: p.format).save!
    end
  end
end

class PodPull < ActiveRecord::Base

  # grabs a random sampling of records from all units in the POD database
  def self.pull_pod_records
    if Recording.all.size > 0
      Recording.delete_all
    end

    Recording.transaction do
      PodUnit.all.each do |u|
        # pull 1 to 10 records from each unit
        how_many = rand(10) + 1
        pos = PodPhysicalObject.joins(:pod_digital_statuses).where("digital_statuses.state = 'archived' and unit_id = #{u.id}").uniq.limit(how_many)
        puts "\n\nSuccessfully pulled #{pos.size} records from #{u.abbreviation}, populating RMD now...\n\n"
        create_rmd_recordings(pos)
      end
    end
  end

  private
  def self.create_rmd_recordings(pod_physical_objects)
    pod_physical_objects.each_with_index do |p, i|
      puts "#{i} of #{pod_physical_objects.size}: #{p.mdpi_barcode}"
      debugger if Recording.where(mdpi_barcode: p.mdpi_barcode).size > 0
      Recording.new(mdpi_barcode: p.mdpi_barcode, title: p.title, format: p.format, access_determination: Recording::DEFAULT_ACCESS, unit: p.pod_unit.abbreviation).save!
    end
  end
end

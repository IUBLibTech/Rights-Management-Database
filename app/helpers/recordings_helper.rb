module RecordingsHelper

  # takes a JSON object from JSON.parse and converts it to Recording objects, saving them in the database
  def save_json(json_text)
    json = JSON.parse json_text
    title = json["title"]
    main_contributors = json["main_contributors"]
    publication_date = json["publication_date"]
    summary = json["summary"]
    fields = json["fields"]
    barcodes = json["fields"]["other_identifier"].select{|i| i.match(/4[0-9]{13}/) }
    last_recording = nil
    Recording.transaction do
      barcodes.each do |bc|
        unit = PodPhysicalObject.where(mdpi_barcode: bc.to_i).first.pod_unit.abbreviation
        recording = Recording.new(
            mdpi_barcode: bc.to_i, title: title, description: summary, access_determination: Recording::DEFAULT_ACCESS,
            published: publication_date, fedora_item_id: json["id"], format: fields["format"],
            atom_feed_read_id: @atom_feed_read.id, unit: unit
        )
        recording.save!
        last_recording = recording
        main_contributors.each do |mc|
          person = Person.new(name: mc)
          person.save!
          recording_contributor_person = RecordingContributorPerson.new(recording_id: recording.id, person_id: person.id)
          recording_contributor_person.save!
        end
      end
      @atom_feed_read.update_attributes(successfully_read: true, json: json_text, avalon_last_updated: @atom_feed_read.avalon_last_updated)
      last_recording
    end
  end

end

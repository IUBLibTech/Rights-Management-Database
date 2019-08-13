module AvalonItemsHelper
  # takes a JSON object from JSON.parse and converts it to Recording objects, saving them in the database
  def save_json(json_text)
    json = JSON.parse json_text
    title = json["title"]
    publication_date = json["publication_date"]
    summary = json["summary"]
    fields = json["fields"]
    barcodes = json["fields"]["other_identifier"].select{|i| i.match(/4[0-9]{13}/) }
    avalon_item = nil
    Recording.transaction do
      unit = PodPhysicalObject.where(mdpi_barcode: barcodes.first.to_i).first.pod_unit.abbreviation
      avalon_item = AvalonItem.new(
          avalon_id: json["id"], title: title, json: json_text, pod_unit: unit
      )
      PastAccessDecision.new(avalon_item: avalon_item, decision: AccessDeterminationHelper::DEFAULT_ACCESS, changed_by: 'automated ingest').save!
      avalon_item.save!
      barcodes.each do |bc|
        unit = PodPhysicalObject.where(mdpi_barcode: bc.to_i).first.pod_unit.abbreviation
        recording = Recording.new(
            mdpi_barcode: bc.to_i, title: title, description: summary, access_determination: Recording::DEFAULT_ACCESS,
            published: publication_date, fedora_item_id: json["id"], format: fields["format"],
            atom_feed_read_id: @atom_feed_read.id, unit: unit, avalon_item_id: avalon_item.id
        )
        recording.save!
      end
      @atom_feed_read.update_attributes(successfully_read: true, avalon_last_updated: @atom_feed_read.avalon_last_updated)
    end
    avalon_item
  end
end

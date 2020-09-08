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
    unit = pod_metadata_unit(barcodes.first)
    Recording.transaction do
      avalon_item = AvalonItem.new(avalon_id: json["id"], title: title, json: json_text, pod_unit: unit, review_state: AvalonItem::REVIEW_STATE_DEFAULT)
      decision = PastAccessDecision.new(avalon_item: avalon_item, decision: AccessDeterminationHelper::DEFAULT_ACCESS, changed_by: 'automated ingest')
      decision.save!
      avalon_item.save!
      barcodes.each do |bc|
        recording = Recording.new(
            mdpi_barcode: bc.to_i, title: title, description: summary, access_determination: Recording::DEFAULT_ACCESS,
            published: publication_date, fedora_item_id: json["id"], atom_feed_read_id: @atom_feed_read.id, unit: unit, avalon_item_id: avalon_item.id,
            copyright_end_date_text: '', date_of_first_publication_text: '', creation_date_text: ''
        )
        recording.save!
      end
      @atom_feed_read.update_attributes(successfully_read: true, avalon_last_updated: @atom_feed_read.avalon_last_updated)
    end
    avalon_item
  end

  def pod_metadata_unit(mdpi_barcode)
    # this is not Java... Strings are full fledged objects and unless you .dup or .clone the secret val, you are changing
    # the value stored at Rails.application.secrets... NOT GOOD
    u = Rails.application.secrets[:pod_full_metadata_url].dup.gsub!(':mdpi_barocde', mdpi_barcode)
    uri = URI.parse(u)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(Rails.application.secrets[:pod_bauth_username], Rails.application.secrets[:pod_bauth_password])
    result = http.request(request).body
    raise "Unit not found" if result.match(/<unit>([-\w]+)<\/unit>/)[1].nil?
    result.match(/<unit>([-\w]+)<\/unit>/)[1]
  end
end

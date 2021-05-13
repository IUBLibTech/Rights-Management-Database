module AfrHelper
  require 'nokogiri'
  require 'net/http'
  require 'uri'

  @@logger ||= Logger.new("#{Rails.root}/log/atom_feed_delayed_job.log")
  POD_GROUP_KEY_SOLR_Q = '/GR[0-9]{8}/'
  ITEMS_PER_PAGE = 100

  # responsible for reading from the atom feed to identify new records that need to be created in RMD
  # It works as follows:
  # 1) determines the timestamp of the last created AtomFeedRead record to know when the last read occurred.
  # 2) iterates through the feed (in newest to oldest order) examining the updated timestamp in the feed and compares
  # it to the timestamp determined in 1)
  # 3) when a timestamp of equal or older value is encountered, there is nothing new in the Atom Feed to read so the process halts
  # 4) for each timestamp that is newer than 1), it represents either a completely new record in MCO OR a record that has been
  # modified in MCO AFTER it was read in RMD. For the former, it creates a new AtomFeedRead object that will get picked
  # up by the JSON reader and subsequently created. For the later, it flags the RMD AvalonItem as modified_in_mco. A
  # subsequent load of the AvalonItem (avalon_item_controller#show) should be responsible for updating the JSON and removing the flag
  def read_atom_feed
    last_read = AtomFeedRead.order("avalon_last_updated DESC").first
    page = 1
    timestamp_reached = false
    more_pages = true
    AtomFeedRead.transaction do
      while more_pages && !timestamp_reached
        uri = gen_atom_feed_uri('desc', ITEMS_PER_PAGE, page)
        response = read_uri(uri)
        xml = parse_xml(response)
        total_records = xml.xpath('//totalResults').first.content.to_f # convert to a float so ceiling will work in division
        start_index = xml.xpath('//startIndex').first.content.to_i
        @@logger.info "\n\n\nProcessing page #{page} of #{(total_records / ITEMS_PER_PAGE).ceil}\n\n\n"
        if start_index < total_records
          xml.xpath('//entry').each do |e|
            title = e.xpath('title').first.content
            avalon_last_updated = DateTime.parse e.xpath('updated').first.content
            json_url = e.xpath('link/@href').first.value
            avalon_item_url = e.xpath('id').first.content
            avalon_id = avalon_item_url.chars[avalon_item_url.rindex('/') + 1..avalon_item_url.length].join("")
            # the very first read of the atom feed, last_read will be nil so read all pages
            if !last_read.nil? && avalon_last_updated <= last_read.avalon_last_updated
              timestamp_reached = true
              break
            else
              # check if this is an existing record that has been altered in MCO since the last read
              if AtomFeedRead.where(avalon_id: avalon_id).exists?
                AvalonItem.where(avalon_id: avalon_id).update_all(modified_in_mco: true)
              else
                AtomFeedRead.new(
                  title: title, avalon_last_updated: avalon_last_updated, json_url: json_url,
                  avalon_item_url: avalon_item_url, avalon_id: avalon_id, entry_xml: e.to_s
                ).save!
              end
            end
          end
          more_pages = (start_index + ITEMS_PER_PAGE) < total_records
          page += 1
        end
      end
    end
  end

  # responsible for reading the atom feed for an existing RMD avalon item to determine if its MCO counterpart has been updated
  # since its last read
  def read_atom_feed_for(avalon_id)

  end

  # responsible for reading the JSON record for an item in MCO
  def read_json(avalon_item)
    uri = URI.parse avalon_item.atom_feed_read.json_url
    json_text = read_uri(uri).body
    avalon_item.update_attributes(json: json_text)
  end

  # responsible for creating the RMD Avalon Item as a result of read_json
  def create_avalon_item(json_read_metadata)

  end

  # responsible for generating the URI to read multiple records from the atom feed
  def gen_atom_feed_uri(order, rows, page, identifier = POD_GROUP_KEY_SOLR_Q)
    URI.parse(Rails.application.secrets[:avalon_url].gsub('<identifier>', identifier).gsub('<order>', order).gsub('<row_count>', rows.to_s).gsub('<page_count>', page.to_s))
  end

  # responsible for generating the URI to read a SINGLE Avalon Items atom feed record
  def gen_atom_feed_uri_for(avalon_id)
    URI.parse(Rails.application.secrets[:avalon_url].gsub('other_identifier_sim:<identifier>&sort=timestamp+<order>&rows=<row_count>&page=<page_count>', "id:#{avalon_id}"))
  end

  # makes a HTTPS request at the specified URI and returns the response
  def read_uri(uri)
    puts "Making MCO service request: #{uri.to_s}"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request['Avalon-Api-Key'] = Rails.application.secrets[:avalon_token]
    http.request(request)
  end

  def parse_xml(response)
    @xml =  @xml = Nokogiri::XML(response.body).remove_namespaces!
  end

end

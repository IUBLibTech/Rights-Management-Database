class AtomFeedReaderTask
  include Delayed::RecurringJob
  #include AtomFeedReaderHelper
  require 'nokogiri'
  require 'net/http'
  require 'uri'

  timezone 'US/Eastern'
  run_every 10.seconds
  run_at Time.now
  queue 'feed-reader'

  @@logger ||= Logger.new("#{Rails.root}/log/atom_feed_delayed_job.log")

  POD_GROUP_KEY_SOLR_Q = '/GR[0-9]{8}/'
  ITEMS_PER_PAGE = 100

  def perform
    last_read = AtomFeedRead.order("avalon_last_updated DESC").first
    page = 1
    timestamp_reached = false
    more_pages = true
    AtomFeedRead.transaction do
      while more_pages && !timestamp_reached
        response = read('desc', ITEMS_PER_PAGE, page)
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

  private
  def read(order, rows, page, identifier = POD_GROUP_KEY_SOLR_Q)
    uri = URI.parse(Rails.application.secrets[:avalon_url].gsub('<identifier>', identifier).gsub('<order>', order).gsub('<row_count>', rows.to_s).gsub('<page_count>', page.to_s))
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
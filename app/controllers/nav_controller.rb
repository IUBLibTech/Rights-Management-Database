class NavController < ApplicationController
  include RecordingsHelper
  include AvalonItemsHelper

  def start
    debugger
    if User.current_user_copyright_librarian?
      @needs_review = AvalonItem.where("needs_review = true AND reviewed is not true AND last_review_comment_by_cm = true")
    else
      units = UnitsHelper.human_readable_units_search(User.current_username)
      @needs_review = AvalonItem.where(needs_review: true, reviewed: [nil, false], pod_unit: units)
    end
  end

  def mdpi_barcode_search
    @recording = Recording.where(mdpi_barcode: params[:mdpi_barcode]).first
    if @recording.nil?
      @atom_feed_read = AtomFeedReaderHelper.read_atom_record(params[:mdpi_barcode])
      # make sure to modify the existing AtomFeedRead object
      if @atom_feed_read
        @existing = AtomFeedRead.where(avalon_id: @atom_feed_read.avalon_id).first
        @atom_feed_read = @existing if @existing
      end
      json_text = AtomFeedReaderHelper.read_avalon_json(@atom_feed_read.json_url) unless @atom_feed_read.nil?
      avalon_item = save_json(json_text) unless @atom_feed_read.nil?
      if avalon_item.nil?
        flash[:warning] = "Could not find any Recordings in MCO with MDPI barcode: #{params[:mdpi_barcode]}"
        redirect_to recordings_path
      else
        flash[:notice] = "New record(s) were loaded into RMD" unless avalon_item.nil?
        redirect_to avalon_item_path(avalon_item) unless avalon_item.nil?
      end
    else
      redirect_to avalon_item_path(@recording.avalon_item)
    end
  end

end
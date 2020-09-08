class NavController < ApplicationController
  include RecordingsHelper
  include AvalonItemsHelper

  def start
    if User.current_user_copyright_librarian?
      @avalon_items = AvalonItem.cl_all
    else
      @avalon_items = AvalonItem.cm_all
    end
  end

  def test

  end

  def avalon_identifier_search

  end

  def date_search_get
    render 'nav/date_search'
  end

  def date_search_post
    if params[:start_year].blank?
      flash[:warning] = "You must specify at least a start year"
      render 'nav/date_search'
    else
      start_date = Date.new(params[:start_year]&.to_i)
      # the year defaults to jan 1, YYYY but for end year the date needs to be Dec 31, YYYY
      end_date = params[:end_year].blank? ? Date.today : Date.new(params[:end_year].to_i + 1) - 1.day
      @avalon_items = AvalonItem.joins(:recordings).where("recordings.date_of_first_publication >= ? and recordings.date_of_first_publication <= ?", start_date, end_date)
      @works = Work.where("publication_date >= ? AND publication_date <= ?", start_date, end_date)
      render 'nav/date_search'
    end
  end

  def search
    @avalon_item = AvalonItem.where(avalon_id: params[:search]).first
    if @avalon_item
      redirect_to @avalon_item
    else
      # try to load atom feed read
    end
  end

  # Search is no longer based on MDPI barcodes, eventually it will entail fedora ids and free text
  # def mdpi_barcode_search
  #   @recording = Recording.where(mdpi_barcode: params[:mdpi_barcode]).first
  #   if @recording.nil?
  #     @atom_feed_read = AtomFeedReaderHelper.read_atom_record(params[:mdpi_barcode])
  #     # make sure to modify the existing AtomFeedRead object
  #     if @atom_feed_read
  #       @existing = AtomFeedRead.where(avalon_id: @atom_feed_read.avalon_id).first
  #       @atom_feed_read = @existing if @existing
  #     end
  #     json_text = AtomFeedReaderHelper.read_avalon_json(@atom_feed_read.json_url) unless @atom_feed_read.nil?
  #     avalon_item = save_json(json_text) unless @atom_feed_read.nil?
  #     if avalon_item.nil?
  #       flash[:warning] = "Could not find any Recordings in MCO with MDPI barcode: #{params[:mdpi_barcode]}"
  #       redirect_to recordings_path
  #     else
  #       flash[:notice] = "New record(s) were loaded into RMD" unless avalon_item.nil?
  #       redirect_to avalon_item_path(avalon_item) unless avalon_item.nil?
  #     end
  #   else
  #     redirect_to avalon_item_path(@recording.avalon_item)
  #   end
  # end

end
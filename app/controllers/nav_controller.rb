class NavController < ApplicationController
  include RecordingsHelper

  def start
    @needs_review = Recording.where(needs_review: true)
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
      last_recording = save_json(json_text) unless @atom_feed_read.nil?
      if last_recording.nil?
        flash[:warning] = "Could not find any Recordings in MCO with MDPI barcode: #{params[:mdpi_barcode]}"
        redirect_to recordings_path
      else
        flash[:notice] = "New record(s) were loaded into RMD" unless last_recording.nil?
        redirect_to recording_path(last_recording) unless last_recording.nil?
      end
    else
      redirect_to recording_path(@recording)
    end
  end

end
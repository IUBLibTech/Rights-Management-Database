class AtomFeedReaderController < ApplicationController
  include RecordingsHelper
  before_action :set_atom_feed_read, only: [:read_json, :load_avalon_record]

  def index
    @atom_feed_reads = AtomFeedRead.where(successfully_read: false).order('avalon_last_updated ASC')
  end

  # action for pre loading the first (oldest) recordings in MCO
  def prepopulate
    AtomFeedReaderHelper.prepopulate
    @atom_feed_reads = AtomFeedRead.where(successfully_read: false).order('avalon_last_updated ASC')
    render 'atom_feed_reader/index'
  end

  # action for triggering a check to see if there are new recordings since the last read in
  def read_current
    AtomFeedReaderHelper.read_current
    @atom_feed_reads = AtomFeedRead.where(successfully_read: false).order('avalon_last_updated ASC')
    render 'atom_feed_reader/index'
  end

  def load_avalon_record
    json_text = AtomFeedReaderHelper.read_avalon_json(@atom_feed_read.json_url)
    last_recording = save_json(json_text)
    flash[:notice] = "New record(s) were loaded into RMD"
    redirect_to recording_path(last_recording) unless last_recording.nil?
    flash[:warning] = "Could not find any Recordings in MCO from URL #{@atom_feed_read.json_url}"
    redirect_to recordings_path
  end

  def read_all_available

  end

  def read_json
    atom_feed_read = AtomFeedRead.find(params[:id])
    @json = AtomFeedReaderHelper.read_avalon_json(atom_feed_read.json_url)
    @json = JSON.parse(@json)
    render 'atom_feed_reader/json'
  end

  private
  def set_atom_feed_read
    @atom_feed_read = AtomFeedRead.find(params[:id])
  end

end

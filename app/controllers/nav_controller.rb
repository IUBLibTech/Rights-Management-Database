class NavController < ApplicationController

  def start
    @needs_review = Recording.where(needs_review: true)
  end

  def mdpi_barcode_search
    @recording = Recording.where(mdpi_barcode: params[:mdpi_barcode]).first
    if @recording.nil?
      render "no_recording"
    else
      redirect_to recording_path(@recording)
    end
  end

end
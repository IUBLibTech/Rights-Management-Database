class NavController < ApplicationController

  def start

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
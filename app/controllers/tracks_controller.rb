class TracksController < ApplicationController
  before_action :set_performance
  def create
    ajax_create_track
  end
  def ajax_new_track
    @performance = Performance.find(params[:performance_id])
    @track = Track.new(performance_id: @performance.id)
    render partial: 'tracks/ajax_new_track'
  end
  def ajax_edit_track

  end
  def ajax_update_track

  end

  def ajax_create_track
    if Track.new(track_params).save!
      render text: 'Track Successfully Created', status: 200
    else
      render text: "An unexpected error occurred trying to create the Track", status: 500
    end
  end

  # DELETE /performances/1
  # DELETE /performances/1.json
  def destroy
    begin
      if @track.destroy
        render text: "success", status: 200
      else
        render text: "An unexpected error occurred trying to delete the Track", status: 500
      end
    rescue
      render text: "An unexpected error occurred trying to delete the specified Performance", status: 500
    end
  end

  private
  def set_performance
    if params[:performance_id]
      @performance = Performance.find(params[:performance_id])
    end
  end
  def track_params
    params.require(:track).permit(
        :performance_id, :track_name, :recording_start_time, :recording_end_time, :in_copyright, :copyright_end_date, :access_determination
    )
  end
end

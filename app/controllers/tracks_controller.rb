class TracksController < ApplicationController

  def ajax_new_track
    @avalon_item = AvalonItem.find(params[:avalon_item_id])
    @performance = Performance.find(params[:performance_id])
    @track = Track.new(performance_id: @performance.id)
    render partial: 'tracks/form'
  end

  def create
    @avalon_item = AvalonItem.find(params[:avalon_item_id])
    @track = Track.new(track_params)
    saved = @track.save
    if saved
      redirect_to @avalon_item, notice: 'Track Successfully Created'
    else
      redirect_to @avalon_item, warning: 'Something went wrong...'
    end
  end

  private
  def track_params
    params.require(:track).permit(
        :performance_id, :track_name, :recording_start_time, :recording_end_time, :in_copyright, :copyright_end_date, :access_determination
    )
  end
end

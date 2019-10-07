class RecordingsController < ApplicationController
  before_action :set_recording, only: [:show, :edit, :update, :destroy, :mark_needs_review, :mark_reviewed]

  # GET /recordings
  # GET /recordings.json
  def index
    @avalon_items = AvalonItem.where(pod_unit: UnitsHelper.human_readable_units_search(User.current_username)).order(:title)
  end

  # GET /recordings/1
  # GET /recordings/1.json
  def show
    if User.belongs_to_unit?(@recording.unit)
      render :show
    else
      render 'recordings/not_authorized'
    end
  end

  # GET /recordings/new
  def new
    @recording = Recording.new
  end

  # GET /recordings/1/edit
  def edit
    render 'recordings/not_authorized' unless User.belongs_to_unit?(@recording.unit)
  end

  # POST /recordings
  # POST /recordings.json
  def create
    @recording = Recording.new(recording_params)
    respond_to do |format|
      if @recording.save
        format.html { redirect_to @recording, notice: 'Recording was successfully created.' }
        format.json { render :show, status: :created, location: @recording }
      else
        format.html { render :new }
        format.json { render json: @recording.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recordings/1
  # PATCH/PUT /recordings/1.json
  def update
    if User.belongs_to_unit?(@recording.unit)
      respond_to do |format|
        if @recording.update(recording_params)
          format.html { redirect_to @recording, notice: 'Recording was successfully updated.' }
          format.json { render :show, status: :ok, location: @recording }
        else
          format.html { render :edit }
          format.json { render json: @recording.errors, status: :unprocessable_entity }
        end
      end
    else
      render 'recordings/not_authorized'
    end
  end

  # DELETE /recordings/1
  # DELETE /recordings/1.json
  def destroy
    if User.belongs_to_unit? @recording.unit
      @recording.destroy
      respond_to do |format|
        format.html { redirect_to recordings_url, notice: 'Recording was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      render 'recordings/not_authorized'
    end
  end

  def mark_needs_review
    @recording.needs_review = true
    @recording.save!
    redirect_to recording_path(@recording)
  end

  def mark_reviewed
    @recording.needs_review = false
    @recording.save!
    redirect_to recording_path(@recording)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recording
      @recording = Recording.includes(recording_contributor_people: [:person]).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recording_params
      params.require(:recording).permit(
          :access_determination, :title, :description, :format, :published, :date_of_first_publication, :creation_date,
          :creation_end_date, :country_of_first_publication, :in_copyright, :copyright_end_date, :receipt_of_will_before_90_days_of_death,
          :authority_source, :authority_source_url
      )
    end
end

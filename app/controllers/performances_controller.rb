class PerformancesController < ApplicationController
  before_action :set_performance, only: [:show, :edit, :update, :destroy]

  # GET /performances
  # GET /performances.json
  def index
    @performances = Performance.all
  end

  # GET /performances/1
  # GET /performances/1.json
  def show
  end

  # GET /performances/new
  def new
    @performance = Performance.new
  end

  # GET /performances/1/edit
  def edit
  end

  # POST /performances
  # POST /performances.json
  def create
    @performance = Performance.new(performance_params)
    Performance.transaction do
      respond_to do |format|
        if @performance.save
          @recording_performance = RecordingPerformance.new(recording_id: params[:recording_id], performance_id: @performance.id)
          if  @recording_performance.save
            @avalon_item = AvalonItem.find(params[:avalon_item_id])
            format.html { redirect_to @avalon_item, notice: 'Performance was successfully created.' }
            format.json { render :show, status: :created, location: @performance }
          else
            format.html { render :new }
            format.json { render json: recording_performance.errors, status: :unprocessable_entity }
          end
        else
          format.html { render :new }
          format.json { render json: @performance.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /performances/1
  # PATCH/PUT /performances/1.json
  def update
    respond_to do |format|
      if @performance.update(performance_params)
        format.html { redirect_to @performance, notice: 'Performance was successfully updated.' }
        format.json { render :show, status: :ok, location: @performance }
      else
        format.html { render :edit }
        format.json { render json: @performance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /performances/1
  # DELETE /performances/1.json
  def destroy
    begin
      @performance.destroy
      render text: "success", status: 200
    rescue

    end
  end

  def ajax_new_performance
    @recording = Recording.find(params[:recording_id])
    @performance = Performance.new
    render partial: 'performances/form'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_performance
      @performance = Performance.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def performance_params
      params.require(:performance).permit(:location, :performance_date)
    end
end

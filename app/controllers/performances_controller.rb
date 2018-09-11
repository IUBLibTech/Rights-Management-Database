class PerformancesController < ApplicationController
  before_action :set_performamce, only: [:show, :edit, :update, :destroy]

  # GET /performances
  # GET /performances.json
  def index
    @performamces = Performance.all
  end

  # GET /performances/1
  # GET /performances/1.json
  def show
  end

  # GET /performances/new
  def new
    @performamce = Performance.new
  end

  # GET /performances/1/edit
  def edit
  end

  # POST /performances
  # POST /performances.json
  def create
    @performamce = Performance.new(performamce_params)

    respond_to do |format|
      if @performamce.save
        format.html { redirect_to @performamce, notice: 'Performance was successfully created.' }
        format.json { render :show, status: :created, location: @performamce }
      else
        format.html { render :new }
        format.json { render json: @performamce.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /performances/1
  # PATCH/PUT /performances/1.json
  def update
    respond_to do |format|
      if @performamce.update(performamce_params)
        format.html { redirect_to @performamce, notice: 'Performance was successfully updated.' }
        format.json { render :show, status: :ok, location: @performamce }
      else
        format.html { render :edit }
        format.json { render json: @performamce.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /performances/1
  # DELETE /performances/1.json
  def destroy
    @performamce.destroy
    respond_to do |format|
      format.html { redirect_to performamces_url, notice: 'Performance was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_performamce
      @performamce = Performance.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def performamce_params
      params.fetch(:performamce, {})
    end
end

class WorksController < ApplicationController
  before_action :set_work, only: [:show, :edit, :update, :destroy]

  # GET /works
  # GET /works.json
  def index
    @works = Work.all
  end

  # GET /works/1
  # GET /works/1.json
  def show
  end

  # GET /works/new
  def new
    @work = Work.new
  end

  # GET /works/1/edit
  def edit
  end

  # POST /works
  # POST /works.json
  def create
    @work = Work.new(work_params)
    respond_to do |format|
      if @work.save
        if params[:avalon_item_id]
          @avalon_item = AvalonItem.find(params[:avalon_item_id])
          AvalonItemWork.new(work_id: @work.id, avalon_item_id: params[:avalon_item_id].to_i).save
        end
        format.html { redirect_to @work, notice: 'Work was successfully created.' }
        format.js {}
        format.json { render text: "success"}
      else
        format.html { render :new }
        format.json { render json: @work.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /works/1
  # PATCH/PUT /works/1.json
  def update
    respond_to do |format|
      if @work.update(work_params)
        format.html { redirect_to @work, notice: 'Work was successfully updated.' }
        format.json { render :show, status: :ok, location: @work }
      else
        format.html { render :edit }
        format.json { render json: @work.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /works/1
  # DELETE /works/1.json
  def destroy
    @work.destroy
    respond_to do |format|
      format.html { redirect_to works_url, notice: 'Work was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def ajax_new_work
    @work = Work.new(title: params[:title])
    @ajax = true
    render partial: 'works/form'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_work
      @work = Work.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def work_params
      params.require(:work).permit(
          :title, :traditional, :contemporary_work_in_copyright, :restored_copyright, :alternative_titles, :publisher,
          :publication_date, :authority_source, :notes, :access_determination, :copyright_end_date, :authority_source_url
      )
    end
end

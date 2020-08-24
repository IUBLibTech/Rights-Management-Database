class WorksController < ApplicationController
  before_action :set_work, only: [:show, :edit, :update, :destroy]

  # GET /works
  # GET /works.json
  def index
    @works = Work.includes(:avalon_items).all
  end

  # GET /works/1
  # GET /works/1.json
  def show
    render 'works/show'
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
    if @work.avalon_items.size > 0
      respond_to do |format|
        format.html { redirect_to works_url, notice: "The Work <i>#{@work.title}</i> cannot be destroyed because it is currently associated with Avalon Items".html_safe }
      end
    else
      @work.destroy
      respond_to do |format|
        format.html { redirect_to works_url, notice: 'Work was successfully destroyed.' }
      end
    end
  end

  def ajax_autocomplete_title
    @hits = Work.where("title like ?", "%#{params[:term]}%")
    render json: @hits
  end
  def ajax_match_authority_source_url
    @hit = Work.where(authority_source_url: params[:term])
    render json: @hit
  end

  def ajax_new_work
    @work = Work.new(title: params[:title])
    @ajax = true
    render partial: 'works/form'
  end

  def ajax_show
    @work = Work.find(params[:id])
    render partial: 'works/ajax_show'
  end

  def ajax_edit_work
    render partial: 'works/ajax_edit_work'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_work
      @work = Work.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def work_params
      params.require(:work).permit(
          :title, :alternative_titles, :publication_date_edtf, :authority_source, :authority_source_url,
          :traditional, :contemporary_work_in_copyright, :restored_copyright, :copyright_renewed,
          :copyright_end_date_edtf, :access_determination, :notes

      )
    end
end

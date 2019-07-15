class AvalonItemsController < ApplicationController

  def index
    @avalon_items = AvalonItem.where(pod_unit: UnitsHelper.human_readable_units_search(User.current_username)).order(:title)
  end

  def show
    @avalon_item = AvalonItem.includes(:recordings).find(params[:id])
    @json = JSON.parse(@avalon_item.json)
    @mdpi_barcodes = parse_bc(@json["fields"]["other_identifier"])
    @atom_feed_read = AtomFeedRead.where("avalon_id like '%#{@avalon_item.avalon_id}'").first
    redirect_to avalon_items_path unless UnitsHelper.unit_member?(User.current_username, @avalon_item.pod_unit)
  end

  def edit

  end

  def update

  end

  def ajax_rmd_metadata
    @avalon_item = AvalonItem.find(params[:id])
    render partial: 'avalon_items/rmd_metadata'
  end

  def ajax_post_access_decision
    @avalon_item = AvalonItem.find(params[:id])
    if @avalon_item
      if @avalon_item.update(access_determination: params[:access])
        render text: "success"
      else
        render text: "An error occurred while attempting to save the Access Determination...", status: 400
      end
    else
      render text: "Could not find Avalon Item with ID: #{params[:id]}", status: 400
    end
  end

  private
  def parse_bc(ids)
    ids.select{|id| id.match(/4[\d]{13}/)}
  end

end

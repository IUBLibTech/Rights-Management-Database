class AvalonItemsController < ApplicationController

  def index
    @avalon_items = AvalonItem.where(pod_unit: UnitsHelper.human_readable_units_search(User.current_username)).order(:title)
  end

  def show
    @avalon_item = AvalonItem.includes(:recordings).find(params[:id])
    @atom_feed_read = AtomFeedRead.where("avalon_id like '%#{@avalon_item.avalon_id}'").first
    redirect_to avalon_items_path unless UnitsHelper.unit_member?(User.current_username, @avalon_item.pod_unit)
  end

end

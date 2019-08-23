class AvalonItemsController < ApplicationController
  include AccessDeterminationHelper

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
      last_decision = @avalon_item.last_copyright_librarian_access_decision
      if is_less_restrictive_than?(params[:access], last_decision&.decision) || User.copyright_librarian?
        pad = PastAccessDecision.new(avalon_item: @avalon_item, changed_by: User.current_username, copyright_librarian: User.copyright_librarian?, decision: params[:access])
        @avalon_item.past_access_decisions << pad
        @avalon_item.save!
        render text: "success"
      else
        render text: "Cannot set access to something less restrictive than last Copyright Librarian access determination", status: 400
      end
    else
      render text: "Could not find Avalon Item with ID: #{params[:id]}", status: 400
    end
  end

  def ajax_post_needs_review
    @avalon_item = AvalonItem.where(id: params[:id]).first
    if @avalon_item.nil?
      render text: "Could Not Find Avalon Item with id: #{params[:id]}", status: 400
    elsif @avalon_item.reviewed?
      render text: "This Avalon Item has already been reviewed by a Copyright Librarian", status: 400
    elsif @avalon_item.needs_review?
      render text: "This Avalon Item has already been marked as needing review.", status: 400
    else
      if @avalon_item.update_attributes(needs_review: true, needs_review_comment: params[:comment], review_requester: User.current_username)
        render text: "Successfully Marked <i>#{@avalon_item.title}</i> as needing review", status: 200
      else
        render text: "Something unexpected happened while trying to mark the recording as needing review", status: 500
      end
    end
  end

  def ajax_post_reviewed
    @avalon_item = AvalonItem.where(id: params[:id]).first
    if @avalon_item.nil?
      render text: "Could Not Find Avalon Item with id: #{params[:id]}", status: 400
    elsif @avalon_item.reviewed?
      render text: "This Avalon Item has already been reviewed by a Copyright Librarian", status: 400
    elsif @avalon_item.needs_review? && User.copyright_librarian?
      if @avalon_item.update_attributes(reviewed: true, reviewed_comment:params[:comment])
        render text: "Successfully Marked <i>#{@avalon_item.title}</i> as reviewed", status: 200
      else
        render text: "Something unexpected happened while trying to mark the recording as needing review", status: 500
      end
    elsif !@avalon_item.needs_reviewed?
      render text: "This record has not been marked as needing review.", status: 400
    else
      render text: "You do not have permission to mark this record reviewed", status: 400
    end
  end

  private
  def parse_bc(ids)
    ids.select{|id| id.match(/4[\d]{13}/)}
  end

end

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
      if is_less_restrictive_than?(params[:access], last_decision&.decision) || User.current_user_copyright_librarian?
        pad = PastAccessDecision.new(avalon_item: @avalon_item, changed_by: User.current_username, copyright_librarian: User.current_user_copyright_librarian?, decision: params[:access])
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
    else
      # who is submitting the comment?
      creator = User.current_username
      cl = User.current_user_copyright_librarian?
      comment = ReviewComment.new(avalon_item_id: @avalon_item.id, creator: creator, copyright_librarian: cl, comment: params[:comment])
      @msg = ""
      begin
        ReviewComment.transaction do
          comment.save!
          if cl
            @avalon_item.update_atttributes!(reviewed: params[:reviewed], last_review_comment_by_cl: true, last_review_comment_by_cm: false)
            @msg = "The collection manager will be notified of your review/comment."
          else
            @avalon_item.update_attributes!(needs_review: true, last_review_comment_by_cl: false, last_review_comment_by_cm: true)
            @msg = "The copyright librarian will be notified of your request/comment."
          end
        end
      rescue => e
        puts e.message
        puts e.backtrace
        @msg = "An error occured while processing the request."
      end
      render text: @msg
    end
  end

  def ajax_post_reviewed
    @avalon_item = AvalonItem.where(id: params[:id]).first
    if @avalon_item.nil?
      render text: "Could Not Find Avalon Item with id: #{params[:id]}", status: 400
    else
      # who is submitting the comment?
      creator = User.current_username
      cl = User.current_user_copyright_librarian?
      comment = ReviewComment.new(avalon_item_id: @avalon_item.id, creator: creator, copyright_librarian: cl, comment: params[:comment])
      @msg = ""
      debugger
      begin
        ReviewComment.transaction do
          comment.save!
          if cl
            @avalon_item.update_attributes!(reviewed: params[:reviewed], last_review_comment_by_cl: true, last_review_comment_by_cm: false)
            @msg = "The collection manager will be notified of your review/comment."
          else
            @avalon_item.update_attributes!(needs_review: true, last_review_comment_by_cl: false, last_review_comment_by_cm: true)
            @msg = "The copyright librarian will be notified of your request/comment."
          end
        end
      rescue => e
        puts e.message
        puts e.backtrace
        @msg = "An error occured while processing the request."
      end
      render text: @msg
    end
  end

  private
  def parse_bc(ids)
    ids.select{|id| id.match(/4[\d]{13}/)}
  end

end

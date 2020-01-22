class AvalonItemsController < ApplicationController
  include AccessDeterminationHelper

  def index
    if User.current_user_copyright_librarian?
      @avalon_items = AvalonItem.all
    else
      @avalon_items = AvalonItem.where(pod_unit: UnitsHelper.human_readable_units_search(User.current_username)).order(:title)
    end
  end

  def show
    @avalon_item = AvalonItem.includes(:recordings).find(params[:id])
    @json = JSON.parse(@avalon_item.json)
    @mdpi_barcodes = parse_bc(@json["fields"]["other_identifier"])
    @atom_feed_read = AtomFeedRead.where("avalon_id like '%#{@avalon_item.avalon_id}'").first
    redirect_to avalon_items_path unless User.belongs_to_unit?(@avalon_item.pod_unit) || User.current_user_copyright_librarian?
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
        rs = pad.decision != AccessDeterminationHelper::DEFAULT_ACCESS ? AvalonItem::REVIEW_STATE_ACCESS_DETERMINED : AvalonItem::REVIEW_STATE_DEFAULT
        @avalon_item.update_attributes!(reviewed: pad.decision != AccessDeterminationHelper::DEFAULT_ACCESS, review_state: rs)
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
      @msg = ""
      begin
        ReviewComment.transaction do
          # CLs cannot initiate review
          if cl && !@avalon_item.needs_review?
            @msg = "Only a collection manager can request review of an item. (You are currently flagged as a Copyright Librarian)"
          elsif cl
            comment = ReviewComment.new(avalon_item_id: @avalon_item.id, creator: creator, copyright_librarian: cl, comment: params[:comment])
            @avalon_item.update_attributes!(reviewed: params[:reviewed], review_state: AvalonItem::REVIEW_STATE_WAITING_ON_CM)
            @msg = "The collection manager will be notified of your review/comment."
            comment.save!
          else
            comment = ReviewComment.new(avalon_item_id: @avalon_item.id, creator: creator, copyright_librarian: cl, comment: params[:comment])
            # differentiate between the FIRST request to review something, and subsequent responses from the CM that provide more information to the CL
            rs = @avalon_item.needs_review ? AvalonItem::REVIEW_STATE_WAITING_ON_CL : AvalonItem::REVIEW_STATE_REVIEW_REQUESTED
            @avalon_item.update_attributes!(needs_review: true, review_state: rs)
            @msg = "The copyright librarian will be notified of your request/comment."
            comment.save!
          end
        end
      rescue => e
        puts e.message
        puts e.backtrace
        @msg = "An error occurred while processing the request."
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
      begin
        ReviewComment.transaction do
          comment.save!
          if cl
            @avalon_item.update_attributes!(reviewed: params[:reviewed], review_state: AvalonItem::REVIEW_STATE_WAITING_ON_CM)
            @msg = "The collection manager will be notified of your review/comment."
          else
            @avalon_item.update_attributes!(needs_review: true, review_state: AvalonItem::REVIEW_STATE_WAITING_ON_CL)
            @msg = "The copyright librarian will be notified of your request/comment."
          end
        end
      rescue => e
        puts e.message
        puts e.backtrace
        @msg = "An error occurred while processing the request."
      end
      render text: @msg
    end
  end

  def ajax_all_cm_items
    @avalon_items = AvalonItem.cm_all
    render partial: 'nav/cm_avalon_items_table'
  end
  def ajax_cm_iu_default_only_items
    @avalon_items = AvalonItem.cm_iu_default
    render partial: 'nav/cm_avalon_items_table'
  end
  def ajax_cm_waiting_on_cl
    @avalon_items = AvalonItem.cm_waiting_on_cl
    render partial: 'nav/cm_avalon_items_table'
  end
  def ajax_cm_waiting_on_self
    @avalon_items = AvalonItem.cm_waiting_on_self
    render partial: 'nav/cm_avalon_items_table'
  end
  def ajax_cm_access_determined
    # FIXME: when RMD is capable of determining when an Avalon Item is published in MCO, this action should omit those items from the result set
    @avalon_items = AvalonItem.cm_access_determined
    render partial: 'nav/cm_avalon_items_table'
  end

  def ajax_all_cl_items
    @avalon_items = AvalonItem.cl_all
    render partial: 'nav/cl_avalon_items_table'
  end
  def ajax_cl_initial_review
    @avalon_items = AvalonItem.cl_initial_review
    render partial: 'nav/cl_avalon_items_table'
  end
  def ajax_cl_waiting_on_self
    @avalon_items = AvalonItem.cl_waiting_on_self
    debgger
    render partial: 'nav/cl_avalon_items_table'
  end
  def ajax_cl_waiting_on_cm
    @avalon_items = AvalonItem.cl_waiting_on_cm
    render partial: 'nav/cl_avalon_items_table'
  end


  private
  def parse_bc(ids)
    ids.select{|id| id.match(/4[\d]{13}/)}
  end

end

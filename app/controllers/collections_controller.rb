class CollectionsController < ApplicationController
  include AccessDeterminationHelper

  def index
    @collection_names = User.user_collections
  end

  def assign_access
    selected = params[:collections]&.keys
    if !selected || selected.size == 0
      flash.now[:warn] = "<p class=\"rvt-alert__message\">You did not select any Collections</p>".html_safe
    elsif selected.size > 0
      if params[:access].blank? && params[:contract_type].blank? && params[:notes].blank?
        flash.now[:warn] = "<p class=\"rvt-alert__message\">You must specify at least an Access Determination, Contract Type, and/or Note</p>".html_safe
      else
        if params[:access]
          @access = PastAccessDecision.new(decision: params[:access], changed_by: User.current_username, copyright_librarian: false)
        end
        if params[:contract_type]
          @contract = Contract.new(
            contract_type: params[:contract_type],
            date_edtf_text: (params[:end_date].blank? ? nil : params[:end_date]),
            perpetual: params[:perpetual].blank? ? nil : params[:perpetual],
            notes: params[:agreement_notes].blank? ? nil : params[:agreement_notes])
        end
        if params[:note]
          @note = AvalonItemNote.new(text: params[:note], creator: User.current_username)
        end
        # dup and save everything
        ais = User.user_collection_ais(selected)
        bad_access = []
        AvalonItem.transaction do
          ais.each do |ai|
            # access can only be set more restrictively than the last Copyright Librarian determination
            if @access
              pad = @access.dup
              last = ai.last_copyright_librarian_access_decision
              if last.nil? || is_more_restrictive_than?(pad.decision, last.decision)
                pad.avalon_item = ai
                ai.current_access_determination = pad
                pad.save
                if pad.decision == AccessDeterminationHelper::DEFAULT_ACCESS
                  ai.review_state = AccessDeterminationHelper::DEFAULT_ACCESS
                else
                  ai.review_state = AvalonItem::REVIEW_STATE_ACCESS_DETERMINED
                end
                ai.save
              else
                bad_access << ai
              end
            end
            if @contract
              con = @contract.dup
              con.avalon_item = ai
              con.save
            end
            if @note
              note = @note.dup
              note.avalon_item = ai
              note.save
            end
          end
        end
        if @access
          flash.now[:notice] = "<p class='rvt-alert rvt-alert--success'>The Access Determination for the selected Collections has been updated to #{params[:access]}</p>".html_safe
          if bad_access.size > 0
            flash.now[:notice] << "<p class='rvt-alert__message'>The Access Determination could not be set for the following "+
              "Avalon #{pluralize bad_access.size, "Item"} because #{params[:access]} is less restrictive than the last determination "+
              "made by the Copyright Librarian.<ul class='rvt-plain-list'>".html_safe
            bad_access.each do |a|
              flash.now[:notice] << "<li><a href='' target='_blank'>#{a.title}</a></li>".html_safe
            end
            flash.now[:notice] << "</ul></p>".html_safe
          end
        end
        if @contract
          flash.now[:notice] << "<p class='rvt-alert rvt-alert--success'>The specified Legal Agreement has been assigned to each Avalon Item in the selected Collections</p>".html_safe
        end
        if @note
          flash.now[:notice] << "<p class='rvt-alert rvt-alert--success'>An Avalon Item Note has been added to each item in the selected Collections</p>".html_safe
        end
      end
    end
    @collection_names = User.user_collections
    render "index"
  end
  def collection_list
    @avalon_items = User.user_collection_ais(params[:collection_name])
    @people = []
    @works = []
    render 'nav/search'
  end
end

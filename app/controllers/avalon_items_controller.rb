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
      #render 'avalon_items/scratch_pad'
  end

  def edit
  end

  def update
  end

  # def ajax_rmd_metadata
  #   @avalon_item = AvalonItem.find(params[:id])
  #   render partial: 'avalon_items/rmd_metadata'
  # end

  def ajax_calced_access
    ai = AvalonItem.find(params[:id])
    render text: ai.calc_access
  end

  def ajax_post_access_decision
    @avalon_item = AvalonItem.find(params[:id])
    if @avalon_item
      last_decision = @avalon_item.last_copyright_librarian_access_decision
      if is_less_restrictive_than?(params[:access], last_decision&.decision) || User.current_user_copyright_librarian?
        pad = PastAccessDecision.new(avalon_item: @avalon_item, changed_by: User.current_username, copyright_librarian: User.current_user_copyright_librarian?, decision: params[:access])
        @avalon_item.past_access_decisions << pad
        # someone reset the review status on the item and has initiated a re-review
        if pad.decision == AccessDeterminationHelper::DEFAULT_ACCESS
          @avalon_item.update_attributes!(review_state: AccessDeterminationHelper::DEFAULT_ACCESS)
        # someone set some access determination other than Default (not reviewed) so mark record reviewed
        else
          @avalon_item.update_attributes!(review_state: AvalonItem::REVIEW_STATE_ACCESS_DETERMINED)
        end
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
          if cl && @avalon_item.default_access?
            @msg = "Only a collection manager can request review of an item. (You are currently flagged as a Copyright Librarian)"
          elsif cl
            comment = ReviewComment.new(avalon_item_id: @avalon_item.id, creator: creator, copyright_librarian: cl, comment: params[:comment])
            @avalon_item.update_attributes!(review_state: AvalonItem::REVIEW_STATE_WAITING_ON_CM)
            @msg = "The collection manager will be notified of your comment."
            comment.save!
          else
            comment = ReviewComment.new(avalon_item_id: @avalon_item.id, creator: creator, copyright_librarian: cl, comment: params[:comment])
            rs = @avalon_item.review_state
            if @avalon_item.default_access? || @avalon_item.access_determined?
              # CM is making initial review request, or a re-review request
              rs = AvalonItem::REVIEW_STATE_REVIEW_REQUESTED
            elsif @avalon_item.waiting_on_cm?
              # CM is responding to CL so switch it to waiting on CL
              rs = AvalonItem::REVIEW_STATE_WAITING_ON_CL
            else
              # CM is adding additional comments - no switch is necessary
            end
            @avalon_item.update_attributes!(review_state: rs)
            @msg = "The copyright librarian will be notified of your request/comment."
            comment.save!
          end
        end
      rescue => e
        puts e.message
        puts e.backtrace
        @msg = "An error occurred while processing the request."
      end
      render partial: 'avalon_items/review_comments'
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
            @avalon_item.update_attributes!(review_state: AvalonItem::REVIEW_STATE_WAITING_ON_CM)
            @msg = "The collection manager will be notified of your review/comment."
          else
            @avalon_item.update_attributes!(review_state: AvalonItem::REVIEW_STATE_WAITING_ON_CL)
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
    render partial: 'nav/cl_avalon_items_table'
  end
  def ajax_cl_access_determined
    @avalon_items = AvalonItem.joins(:past_access_decisions).where(past_access_decisions: {copyright_librarian: true}).uniq
    render partial: 'nav/cl_avalon_items_table'
  end
  def ajax_cl_waiting_on_cm
    @avalon_items = AvalonItem.cl_waiting_on_cm
    render partial: 'nav/cl_avalon_items_table'
  end

  def ajax_people_setter
    @avalon_item = AvalonItem.find(params[:id])
    @person = Person.find(params[:pid])
    # render partial: 'avalon_items/ajax_people_adder'
    @existing = true
    render partial: 'avalon_items/ajax_people_add'
  end


  def ajax_people_setter_post
    respond_to do |format|
      @avalon_item = AvalonItem.find(params[:id])
      @person = Person.find(params[:person][:id])
      Person.transaction do
        @updated = @person.update(person_params)
        # this is a complicated mess of logic because, the internet plus rails plus IU Rivet...
        #
        # contributions to Recordings/Performances/Tracks are role based. The role is stored at the xyzContributorPerson
        # object as a boolean (RecordingContributorPerson.depositor for instance). Since HTML does not post unchecked checkboxes
        # and I was unable to figure out how to get the Rails to do this for nested nested nested nested associations, this
        # is done by manually creating input type=checkbox HTML rather than relying on the Rails form builder helpers.
        # To check for unchecked checkboxes we have to see what's missing from the form. At each
        # level of the AvalonItem hierarchy (Recording/Performance/Track), we need to do the following:
        # 1) determine the Recording/Performance/Track ids of all items currently associated with the AvalonItem
        # 2) determine the Recording/Performance/Track ids that were submitted in the form on a role by role basis
        # 3) determine what ids are NOT PRESENT in the form for a specific role, but ARE PRESENT in existing for that role.
        # These ids represent the User unchecking that role and need to be set to false
        # 4) determine what ids ARE PRESENT in the form for a specific role but are NOT PRESENT in existing for that role.
        # These are roles that the User is adding to the association and need to be set to true or (see below) created in
        # the xyzContributePerson object
        # 6) if a user contributes a role to the object but there is no xyzContributorPerson object for that
        # pairing, create the object and set the associated role(s) to true

        recording_ids = @avalon_item.recordings.pluck(:id)
        # all RecordingContributorPerson entries for this AvalonItem's Recordings, that @person is associated with. This
        # may not be an assigned role as unchecking a role does not remove the RecordingContributorPerson, it only sets
        # the boolean to false. It's possible to have previously created entries end up with all roles as null or false
        existing_recordings = RecordingContributorPerson.where(recording_id: recording_ids, person_id: @person.id)
        # all EXISTING RecordingContributorPersons that @person contributes to as a Depositor
        existing_depositors = existing_recordings.where(recording_depositor: true)
        # what is originally there but NOT in the form submission, remove these roles
        remove_depositor_ids = existing_depositors.pluck(:id) - recording_depositor_ids
        existing_depositors.where(id: remove_depositor_ids).update_all(recording_depositor: false)
        # what is originally there but NOT in the form submission, remove these roles
        existing_producers = existing_recordings.where(recording_producer: true)
        remove_producer_ids =  existing_producers.pluck(:id) - recording_producer_ids
        existing_producers.where(id: remove_producer_ids).update_all(recording_producer: false)

        # a RecordingContributorPerson may or may not exist yet for new checks (see above),
        # so we need to identify those and create new RecordingContributorPeople for each
        add_depositor_ids = recording_depositor_ids - existing_depositors.pluck(:id) # everything that needs to be set to true but not necessarily existing as yet
        add_producer_ids = recording_producer_ids
        add_depositor_ids.each do |r_id|
          rcp = existing_recordings.where(recording_id: r_id).first
          if rcp.nil?
            rcp = RecordingContributorPerson.new(recording_id: r_id, person_id: @person.id)
            rcp.save!
          end
          rcp.update!(recording_depositor: true)
        end
        add_producer_ids.each do |r_id|
          rcp = existing_recordings.where(recording_id: r_id).first
          if rcp.nil?
            rcp = RecordingContributorPerson.new(recording_id: r_id, person_id: @person.id)
            rcp.save!
          end
          rcp.update!(recording_producer: true)
        end

        # PERFORMANCE associations no longer exists, those roles have been moved into TrackContributorPerson but we
        # still need to grab all the tracks for all the performances
        existing_performances = Recording.where(id: recording_ids)
        all_performance_ids = existing_performances.collect { |r| r.performances.collect{|p| p.id} }.flatten

        # Track associations
        all_track_ids = Performance.where(id: all_performance_ids).collect{|p| p.tracks.pluck(:id) }.flatten
        existing_tcp = TrackContributorPerson.where(track_id: all_track_ids, person_id: @person.id)

        # now remove any associations the User deselected in the form
        # interviewer role
        existing_interviewers = existing_tcp.where(interviewer: true)
        remove_interviewer_ids = existing_interviewers.pluck(:id) - track_interviewer_ids
        existing_interviewers.where(id: remove_interviewer_ids).update_all(interviewer: false)
        # interviewee (the person interviewed)
        existing_interviewees = existing_tcp.where(interviewee: true)
        remove_interviewee_ids = existing_interviewees.pluck(:id) - track_interviewee_ids
        existing_interviewees.where(id: remove_interviewee_ids).update_all(interviewee: false)
        # performers
        existing_performers = existing_tcp.where(performer: true)
        remove_performer_ids = existing_performers.pluck(:id) - track_performer_ids
        existing_performers.where(id: remove_performer_ids).update_all(performer: false)
        # conductors
        existing_conductors = existing_tcp.where(conductor: true)
        remove_conductor_ids = existing_conductors.pluck(:id) - track_conductor_ids
        existing_conductors.where(id: remove_conductor_ids).update_all(conductor: false)
        # now add any associations that were not already checked in the form, this entails first looking up whether a
        # PerformanceContributorPerson exists or creating one, then setting the boolean
        add_interviewer_ids = track_interviewer_ids
        add_interviewer_ids.each do |i|
          e = existing_tcp.where(track_id: i).first
          if e.nil?
            e = TrackContributorPerson.new(track_id: i, person_id: @person.id)
            e.save!
          end
          e.update!(interviewer: true)
        end
        add_interviewee_ids = track_interviewee_ids - existing_interviewees.pluck(:id)
        add_interviewee_ids.each do |i|bugs

          e = existing_tcp.where(track_id: i).first
          if e.nil?
            e = TrackContributorPerson.new(track_id: i, person_id: @person.id)
            e.save!
          end
          e.update!(interviewee: true)
        end
        add_performer_ids = track_performer_ids - existing_performers.pluck(:id)
        add_performer_ids.each do |i|
          e = existing_tcp.where(track_id: i).first
          if e.nil?
            e = TrackContributorPerson.new(track_id: i, person_id: @person.id)
            e.save!
          end
          e.update!(performer: true)
        end
        add_conductor_ids = track_conductor_ids - existing_conductors.pluck(:id)
        add_conductor_ids.each do |i|
          e = existing_tcp.where(track_id: i).first
          if e.nil?
            e = TrackContributorPerson.new(track_id: i, person_id: @person.id)
            e.save!
          end
          e.update!(conductor: true)
        end
      end
      if @updated
        format.html { redirect_to @avalon_item, notice: 'Person/Entity successfully updated' }
        format.js   {}
        format.json { render json: @avalon_item, status: :created, location: @avalon_item }
      else
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  def ajax_people_adder
    @avalon_item = AvalonItem.find(params[:id])
    @person = Person.new
    if params[:text]
      if params[:text].include?(',')
        words = params[:text].split(',').collect { |x| x.strip }
        @person.first_name = words[1]
        @person.last_name = words[0]
      elsif params[:text].include?(' ')
        words = params[:text].split(' ').collect { |x| x.strip }
        @person.first_name = words[0]
        @person.last_name = words[1]
      else
        @person.first_name = params[:text]
      end
    end
    # render partial: 'avalon_items/ajax_people_adder'
    render partial: 'avalon_items/ajax_people_add'
  end
  def ajax_people_adder_post
    Person.transaction do
      @person = Person.new(person_params)
      saved = @person.save
      recording_contribution_ids.each do |id|
        RecordingContributorPerson.new(recording_id: id.to_i, person_id: @person.id, recording_depositor: recording_depositor_ids.include?(id), recording_producer: recording_producer_ids.include?(id)).save
      end
      # the TrackContributorPerson may already exist with no role set to true, don't recreate them...
      track_contribution_ids.each do |id|
        TrackContributorPerson.new(
            person_id: @person.id, track_id: id.to_i,
            interviewer: track_interviewer_ids.include?(id),
            interviewee: track_interviewee_ids.include?(id),
            performer: track_performer_ids.include?(id),
            conductor: track_conductor_ids.include?(id)
        ).save
      end
      respond_to do |format|
        if saved
          format.html { redirect_to @avalon_item, notice: 'Person was successfully created.' }
          format.js   {}
          format.json { render json: @avalon_item, status: :created, location: @avalon_item }
        else
          format.json { render json: @person.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def ajax_work_setter
    @avalon_item = AvalonItem.find(params[:id])
    @work = Work.find(params[:wid])
    @existing = true
    render partial: 'avalon_items/ajax_work_adder'
  end

  def ajax_work_setter_post
    respond_to do |format|
      @avalon_item = AvalonItem.find(params[:id])
      @work = Work.find(params[:work][:id])
      Work.transaction do
        @updated = @work.update(work_params)
        # Tracks: get all the track associations for the AvalonItem first
        existing_tracks = @avalon_item.recordings.collect{|r| r.performances }.flatten.collect{|p| p.tracks }.flatten
        # determine which tracks have the specified work performed on them.
        existing_track_ids_with_work = existing_tracks.select { |t| @work.performed_on_track?(t.id) }.collect{|t| t.id }
        form_track_ids = params[:tracks].blank? ? [] : params[:tracks].keys.map(&:to_i)

        # anything in form_track_ids and NOT in existing_track_ids is a new association
        new_ones = form_track_ids - existing_track_ids_with_work
        new_ones.each do |tid|
          TrackWork.new(track_id: tid, work_id: @work.id).save!
        end
        # anything in existing_track_ids_with_work and NOT in form_track_ids is the User REMOVING the association in the edit
        delete = existing_track_ids_with_work - form_track_ids
        delete.each do |tid|
          TrackWork.where(track_id: tid, work_id: @work.id).delete_all
        end
        # process people:
        # need to re-save @work as any NEW people are enqueued into @work.work_contributor_people and the save results in the
        # new work contributor people persisting in the database
        process_work_contributors
        @updated = @work.save
      end
      if @updated
        format.html { redirect_to @avalon_item, notice: 'Work successfully updated' }
        format.js   {}
        format.json { render json: @avalon_item, status: :created, location: @avalon_item }
      else
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end
  def ajax_work_adder
    @avalon_item = AvalonItem.includes(recordings: [performances: [:tracks]]).find(params[:id])
    @work = Work.new
    if params[:text]
      @work.title = params[:text]
    end
    render partial: 'avalon_items/ajax_work_adder'
  end
  def ajax_work_adder_post
    Work.transaction do
      @work = Work.new(work_params)
      if params[:tracks]
        new_ones = params[:tracks].keys.map(&:to_i)
        new_ones.each do |t|
          @work.track_works << TrackWork.new(track_id: t.to_i, work_id: @work.id)
        end
        process_work_contributors
      end
      @work.save!
      respond_to do |format|
        if @work.save
          format.html { redirect_to @avalon_item, notice: 'Work was successfully created.' }
          format.js   {}
          format.json { render json: @avalon_item, status: :created, location: @avalon_item }
        else
          format.json { render json: @work.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def ajax_add_note
    @avalon_item = AvalonItem.find(params[:id])
    ain = AvalonItemNote.new(text: params[:text], creator: User.current_username, avalon_item_id: @avalon_item.id)
    ain.save
    render partial: 'avalon_items/notes'
  end

  private
  def parse_bc(ids)
    ids.select{|id| id.match(/4[\d]{13}/)}
  end

  def work_params
    params.require(:work).permit([
     :title, :alternative_titles, :publication_date_edtf, :authority_source, :authority_source_url,
     :traditional, :contemporary_work_in_copyright, :restored_copyright, :copyright_renewed,
     :copyright_end_date_edtf, :access_determination, :notes
     ])
  end

  def person_params
    params.require(:person).permit(
        :first_name, :middle_name, :last_name, :date_of_birth_edtf, :date_of_death_edtf, :place_of_birth,
    :authority_source, :authority_source_url, :aka, :notes, :entity, :company_name, :entity_nationality
    )
  end

  def process_work_contributors
    # now handle any additions/subtractions from the work contributors
    existing_contributors = @work.people
    existing_contributor_ids = existing_contributors.collect{|p| p.id}
    form_people_ids = params[:work_people].blank? ? [] : params[:work_people].keys.map(&:to_i)
    # people ids that appear in the form but are not already associated with the work
    new_people_ids = form_people_ids - existing_contributor_ids
    new_people_ids.each do |pid|
      roles = params[:work_people][pid.to_s]
      wc = WorkContributorPerson.new(work_id: @work.id, person_id: pid, principle_creator: roles.keys.include?("principle_creator"), contributor: roles.keys.include?("contributor"))
      @work.work_contributor_people << wc
    end
    # people ids that appear in the form AND currently exist on the work may have had their roles change
    existing_people_ids = existing_contributor_ids & form_people_ids
    existing_people_ids.each do |pid|
      roles = params[:work_people][pid.to_s]
      WorkContributorPerson.where(work_id: @work.id, person_id: pid).update_all(principle_creator: roles.keys.include?("principle_creator"), contributor: roles.keys.include?("contributor"))
    end
    # existing contributors that DO NOT appear in the form have had their associations remove, delete these
    remove_contributors = existing_contributor_ids - form_people_ids
    WorkContributorPerson.where(work_id: @work.id, person_id: remove_contributors).delete_all
  end

  # all recording ids that @person contributes to in SOME way
  def recording_contribution_ids
    (recording_producer_ids + recording_depositor_ids).uniq
  end
  # Extracts the RECORDING ids from the form submission for a specified Person with Recording role Producer checked - these
  # are associations that need to exist (or already exist)
  def recording_producer_ids
    param_role_extractor(:recording_contributors, :producers)
  end
  # Extracts the RECORDING ids from the form submission for a specified Person with Recording role Depositor checked - these
  # are associations that need to exist (or already exist)
  def recording_depositor_ids
    param_role_extractor(:recording_contributors, :depositors)
  end
  # all performance ids that @person contributes to in SOME way
  def track_contribution_ids
    (track_interviewee_ids + track_interviewer_ids + track_conductor_ids + track_performer_ids).uniq
  end
  # Extracts the PERFORMANCE ids from the form submission for a specified Person with Performance role Interviewer checked - these
  # are associations that need to exist (or already exist)
  def track_interviewer_ids
    param_role_extractor(:track_contributors, :interviewers)
  end
  # Extracts the PERFORMANCE ids from the form submission for a specified Person with Performance role Performer checked - these
  # are associations that need to exist (or already exist)
  def track_performer_ids
    param_role_extractor(:track_contributors, :performers)
  end
  # Extracts the PERFORMANCE ids from the form submission for a specified Person with Performance role Conductor checked - these
  # are associations that need to exist (or already exist)
  def track_conductor_ids
    param_role_extractor(:track_contributors, :conductors)
  end
  # Extracts the PERFORMANCE ids from the form submission for a specified Person with Performance role Interviewee checked - these
  # are associations that need to exist (or already exist)
  def track_interviewee_ids
    param_role_extractor(:track_contributors, :interviewees)
  end
  # Extracts the TRACK ids from the form submission for a specified Person with Track role Contributor checked - these
  # are associations that need to exist (or already exist)
  def track_contributor_ids
    param_role_extractor(:track_contributors, :contributors)
  end


  def param_role_extractor(element_sym, role_sym)
    if params[element_sym] && params[element_sym][role_sym]
      params[element_sym][role_sym].keys.map(&:to_i)
    else
      []
    end
  end

end

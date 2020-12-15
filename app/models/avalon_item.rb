class AvalonItem < ActiveRecord::Base
  include AccessDeterminationHelper
  has_many :recordings
  has_many :performances, through: :recordings
  has_many :tracks, through: :performances
  has_many :works, through: :tracks
  has_many :past_access_decisions
  has_many :avalon_item_notes
  has_many :review_comments
  belongs_to :current_access_determination, class_name: 'PastAccessDecision', foreign_key: 'current_access_determination_id', autosave: true

  accepts_nested_attributes_for :performances

  # after_create :index_solr

  REVIEW_STATE_DEFAULT = 0
  REVIEW_STATE_REVIEW_REQUESTED = 1
  REVIEW_STATE_WAITING_ON_CM = 2
  REVIEW_STATE_WAITING_ON_CL = 3
  REVIEW_STATE_ACCESS_DETERMINED = 4

  scope :cl_all, -> {
    where(review_state: [REVIEW_STATE_REVIEW_REQUESTED, REVIEW_STATE_WAITING_ON_CM, REVIEW_STATE_WAITING_ON_CL])
  }
  scope :cl_initial_review, -> {
    AvalonItem.where(review_state: REVIEW_STATE_REVIEW_REQUESTED)
  }
  scope :cl_waiting_on_self, -> {
    where(review_state: REVIEW_STATE_WAITING_ON_CL)
  }
  scope :cl_waiting_on_cm, -> {
    where(review_state: AvalonItem::REVIEW_STATE_WAITING_ON_CM)
  }

  scope :cm_all, -> {
    # FIXME: when there is a way to detect when an Avalon Item is published in Avalon, we'll need to filter this query
    # omitting those items - that's the only way they clear from the Collection Managers queue
    where(:pod_unit => UnitsHelper.human_readable_units_search(User.current_username))
  }
  scope :cm_iu_default, -> {
    AvalonItem.where(pod_unit: UnitsHelper.human_readable_units_search(User.current_username)).where("review_state = #{AvalonItem::REVIEW_STATE_DEFAULT}")
  }
  scope :cm_waiting_on_cl, -> {
    AvalonItem.where(pod_unit: UnitsHelper.human_readable_units_search(User.current_username))
        .where("review_state = #{AvalonItem::REVIEW_STATE_WAITING_ON_CL} OR review_state = #{AvalonItem::REVIEW_STATE_REVIEW_REQUESTED}")
  }
  scope :cm_waiting_on_self, -> {
    AvalonItem.where(pod_unit: UnitsHelper.human_readable_units_search(User.current_username), review_state: REVIEW_STATE_WAITING_ON_CM)
  }
  # FIXME: need to updated this after there is a way to determine and flag an AvalonItem as having been published in MCO - this scope should omit those results
  scope :cm_access_determined, -> {
    AvalonItem.where(pod_unit: UnitsHelper.human_readable_units_search(User.current_username), review_state: REVIEW_STATE_ACCESS_DETERMINED)
  }

  # searchable do
  #   text :title, :avalon_id
  #   text :recordings do
  #     recordings.map{ |r| [r.title, r.description, r.mdpi_barcode.to_s]}
  #   end
  #   text :performances do
  #     performances.map{ |p| p.title }
  #   end
  #   text :tracks do
  #     tracks.map {|t| t.track_name}
  #   end
  #   text :works do
  #     works.map { |w| [w.title, w.people.map {|p| p.name }]}
  #   end
  #   text :people do
  #     recordings.map {|r| r.contributors}
  #   end
  #
  #   string :current_access_determination do
  #     current_access_determination.nil? ? AccessDeterminationHelper::DEFAULT_ACCESS : current_access_determination.decision
  #   end
  # end

  def has_rmd_metadata?
    recordings.collect{|r| r.performances.size}.inject(0){|sum, x| sum + x} > 0
  end

  def access_determination
    past_access_decisions.last.decision
  end

  def last_copyright_librarian_access_decision
    past_access_decisions.where(copyright_librarian: true).last
  end

  def allowed_access_determinations
    if User.current_user_copyright_librarian?
      ACCESS_DECISIONS
    else
      allowed = []
      max = ACCESS_RANKING[last_copyright_librarian_access_decision.nil? ? AccessDeterminationHelper::WORLD_WIDE_ACCESS : last_copyright_librarian_access_decision.decision]
      ACCESS_RANKING.each do |key, value|
        if value <= max
          allowed << key
        end
      end
      allowed
    end
  end

  def self.most_restrictive_access(args)
    actual = nil
    args.each do |a|
      raise "Not a valid Access Determination - #{a}" unless ACCESS_DECISIONS.include? a
      actual = a if actual.nil? || ORDERED_ACCESS_DECISIONS.find_index(a) < ORDERED_ACCESS_DECISIONS.find_index(actual)
    end
    actual
  end

  def avalon_url
    Rails.application.secrets.avalon_media_url.gsub!(":id", self.avalon_id)
  end

  def default_access?
    review_state == REVIEW_STATE_DEFAULT
  end
  def review_requested?
    review_state == REVIEW_STATE_REVIEW_REQUESTED
  end
  def waiting_on_cm?
    review_state == REVIEW_STATE_WAITING_ON_CM
  end
  def waiting_on_cl?
    review_state == REVIEW_STATE_WAITING_ON_CL
  end
  def access_determined?
    review_state == REVIEW_STATE_ACCESS_DETERMINED
  end

  def in_review?
    [REVIEW_STATE_REVIEW_REQUESTED, REVIEW_STATE_WAITING_ON_CM, REVIEW_STATE_WAITING_ON_CL].include? review_state
  end

  # determines the most restrictive access of any constituents of this Avalon Item (Recordings, Tracks, People, Works)
  def calc_access
    perf_acc = performances.collect{|p| p.access_determination }
    # FIXME: for some inexplicable reason this hangs indefinitely
    # track_acc = tracks.collect{|t| t.access_determination }
    tracks = performances.collect{|p| p.tracks}.flatten
    track_acc = tracks.collect{|t| t.access_determination}.flatten
    work_acc = tracks.collect{|t| t.works }.flatten.uniq.collect{|w| w.access_determination }
    all = (perf_acc + track_acc + work_acc).uniq
    if all.include? AccessDeterminationHelper::RESTRICTED_ACCESS
      AccessDeterminationHelper::RESTRICTED_ACCESS
    elsif all.include? AccessDeterminationHelper::IU_ACCESS
      AccessDeterminationHelper::IU_ACCESS
    elsif all.include? AccessDeterminationHelper::DEFAULT_ACCESS
      AccessDeterminationHelper::DEFAULT_ACCESS
    elsif all.include? AccessDeterminationHelper::WORLD_WIDE_ACCESS
      AccessDeterminationHelper::WORLD_WIDE_ACCESS
    else
      AccessDeterminationHelper::DEFAULT_ACCESS
    end
  end

  def cl_determined?
    past_access_decisions.where(copyright_librarian: true).any?
  end

  def any_determinations?
    past_access_decisions.where.not(decision: AccessDeterminationHelper::DEFAULT_ACCESS).any?
  end

  # this function reads the MCO atom feed for this item, comparing it's <updated> timestamp to
  # the stored timestamp from its last read atom feed object. If the read has a newer date, there is potentially
  # new data that the user will want to import into RMD.
  def new_mco_data?
    afr = AtomFeedRead.where(avalon_id: self.avalon_id).first

  end

  def rivet_button_badge
    text = ""
    css = ""
    if reviewed?
      text = "Access Determined"
      css = "rvt-badge rvt-badge--success"
    else
      if User.current_user_copyright_librarian?
        case review_state
        when REVIEW_STATE_DEFAULT
          text = "Default Access"
          css = "rvt-badge rvt-badge--info"
        when REVIEW_STATE_REVIEW_REQUESTED
          text = (any_determinations? ? "Re-Review" : "Initial Review")
          css = "rvt-badge rvt-badge--info"
        when REVIEW_STATE_WAITING_ON_CM
          text = "Needs Information"
          css = "rvt-badge rvt-badge--warning"
        when REVIEW_STATE_WAITING_ON_CL
          text = "Responses"
          css = "rvt-badge rvt-badge--danger"
        else
          return ""
        end
      else
        case review_state
        when REVIEW_STATE_DEFAULT
          text = "Default Access"
          css = "rvt-badge rvt-badge--info"
        when REVIEW_STATE_REVIEW_REQUESTED
          text = "Review Requested"
          css = "rvt-badge rvt-badge--warning"
        when REVIEW_STATE_WAITING_ON_CM
          text = "Responses"
          css = "rvt-badge rvt-badge--danger"
        when REVIEW_STATE_WAITING_ON_CL
          text = "Review Requested"
          css = "rvt-badge rvt-badge--warning"
        when REVIEW_STATE_ACCESS_DETERMINED
          text = "Access Determined"
          css = "rvt-badge rvt-badge--success"
        else
          return ""
        end
      end
    end
    "<span class='#{css}'>#{text}</span>".html_safe
  end

  # def index_solr
  #   Sunspot.index(self)
  # end

end

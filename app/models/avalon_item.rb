class AvalonItem < ActiveRecord::Base
  include AccessDeterminationHelper
  has_many :recordings
  has_many :past_access_decisions
  has_many :avalon_item_notes
  has_many :review_comments
  belongs_to :current_access_determination, class_name: 'PastAccessDecision', foreign_key: 'current_access_determination_id', autosave: true

  REVIEW_STATE_DEFAULT = 0
  REVIEW_STATE_REVIEW_REQUESTED = 1
  REVIEW_STATE_WAITING_ON_CM = 2
  REVIEW_STATE_WAITING_ON_CL = 3
  REVIEW_STATE_ACCESS_DETERMINED = 4

  scope :cl_all, -> {
    where(needs_review: true, reviewed: [false, nil])
  }
  scope :cl_initial_review, -> {
    AvalonItem.where(needs_review: true, review_state: REVIEW_STATE_REVIEW_REQUESTED)
  }
  scope :cl_waiting_on_self, -> {
    where(reviewed: false, needs_review: true, review_state: REVIEW_STATE_WAITING_ON_CL)
  }
  scope :cl_waiting_on_cm, -> {
    where(reviewed: false, needs_review: true, review_state: AvalonItem::REVIEW_STATE_WAITING_ON_CM)
  }

  scope :cm_all, -> {
    # FIXME: when there is a way to detect when an Avalon Item is published in Avalon, we'll need to filter this query
    # omitting those items - that's the only way they clear from the Collection Managers queue
    where(:pod_unit => UnitsHelper.human_readable_units_search(User.current_username))
  }
  scope :cm_iu_default, -> {
    AvalonItem.where(needs_review: [nil,false], pod_unit: UnitsHelper.human_readable_units_search(User.current_username))
        .joins(:current_access_determination).where("past_access_decisions.decision = '#{AccessDeterminationHelper::DEFAULT_ACCESS}'")
  }
  scope :cm_waiting_on_cl, -> {
    AvalonItem.where(pod_unit: UnitsHelper.human_readable_units_search(User.current_username))
        .where("review_state = #{AvalonItem::REVIEW_STATE_WAITING_ON_CM} OR review_state = #{AvalonItem::REVIEW_STATE_REVIEW_REQUESTED}")
  }
  scope :cm_waiting_on_self, -> {
    AvalonItem.where(pod_unit: UnitsHelper.human_readable_units_search(User.current_username), review_state: REVIEW_STATE_WAITING_ON_CM)
  }
  # FIXME: need to updated this after there is a way to determine and flag an AvalonItem as having been published in MCO - this scope should omit those results
  scope :cm_access_determined, -> {
    AvalonItem.where(pod_unit: UnitsHelper.human_readable_units_search(User.current_username), review_state: REVIEW_STATE_ACCESS_DETERMINED)
  }

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

  # returns true if the AvalonItem has NOT been flagged for review AND access detemriniation is DEFAULT_ACCESS
  def iu_default_only?
    access_determination == DEFAULT_ACCESS && !needs_review
  end
  def initial_review?
    needs_review && review_state == AvalonItem::REVIEW_STATE_REVIEW_REQUESTED
  end
  def needs_cl_info?
    needs_review && !reviewed && review_state == AvalonItem::REVIEW_STATE_WAITING_ON_CL
  end
  def needs_cm_info?
    needs_review && !reviewed && review_state == AvalonItem::REVIEW_STATE_WAITING_ON_CM
  end
  def access_determined?
    review_state == AvalonItem::REVIEW_STATE_ACCESS_DETERMINED
  end

  def rivet_button_badge
    text = ""
    css = ""
    if User.current_user_copyright_librarian?
      case review_state
      when REVIEW_STATE_DEFAULT
        return ""
      when REVIEW_STATE_REVIEW_REQUESTED
        text = "Initial Review"
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
    "<span class='#{css}'>#{text}</span>".html_safe
  end


end

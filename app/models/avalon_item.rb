class AvalonItem < ActiveRecord::Base
  include AccessDeterminationHelper
  has_many :recordings
  has_many :past_access_decisions
  has_many :avalon_item_notes
  has_many :review_comments

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

end

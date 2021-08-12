class TrackContributorPerson < ActiveRecord::Base
  belongs_to :person
  belongs_to :track
end

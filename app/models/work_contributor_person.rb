class WorkContributorPerson < ActiveRecord::Base
  belongs_to :work
  belongs_to :person
end

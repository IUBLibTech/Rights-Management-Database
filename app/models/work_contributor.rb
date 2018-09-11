class WorkContributor < ActiveRecord::Base
  belongs_to :work
  belongs_to :role
  belongs_to :person
end

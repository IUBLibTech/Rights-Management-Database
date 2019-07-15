class Work < ActiveRecord::Base
  has_many :performances
  has_many :work_contributor_people
  has_many :people, through: :work_contributor_people
  has_many :avalon_item_works
  has_many :avalon_items, through: :avalon_item_works
  #alias_attribute :work_contributors, :people
end

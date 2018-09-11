class Role < ActiveRecord::Base
  has_many :work_contributors
  has_many :works, through: :work_contributors
  has_many :performance_contributors
  has_many :people, as: :performers
end

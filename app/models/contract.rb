class Contract < ActiveRecord::Base
  has_many :performance_contributors
  has_many :people, through: :performance_contributors
end

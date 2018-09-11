class PersonNationality < ActiveRecord::Base
  belongs_to :person
  belongs_to :nationality
end

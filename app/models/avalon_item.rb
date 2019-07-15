class AvalonItem < ActiveRecord::Base
  has_many :recordings
  has_many :avalon_item_works
  has_many :works, through: :avalon_item_works
  has_many :avalon_item_people
  has_many :people, through: :avalon_item_people

  def has_rmd_metadata?
    works.size > 0
  end
end

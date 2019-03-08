class Recording < ActiveRecord::Base
  # has_many :recording_performances
  # has_many :performances, through: :recording_performances
  validates :mdpi_barcode, presence: true, uniqueness: true
end

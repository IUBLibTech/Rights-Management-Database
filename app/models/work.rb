class Work < ActiveRecord::Base
  has_many :performances
  has_many :work_contributor_people
  has_many :people, through: :work_contributor_people
  has_many :avalon_item_works
  has_many :avalon_items, through: :avalon_item_works
  before_save :convert_edtf
  has_many :track_works
  has_many :tracks, through: :track_works
  #alias_attribute :work_contributors, :people

  # This method ensures that when an EDTF text date is modified (added, changed or removed), that the underlying
  # DB Date reflects that
  def convert_edtf
    self.publication_date = publication_date_edtf.blank? ? nil : Date.edtf(publication_date_edtf)
    self.copyright_end_date = copyright_end_date_edtf.blank? ? nil : Date.edtf(copyright_end_date_edtf)
  end
  def label
    title
  end
  def value
    id
  end
  def as_json(options)
    json = super(methods: [:label, :value])
    Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  end

  def performed_on_track?(tid)
    track_works.where(track_id: tid).size > 0
  end
end

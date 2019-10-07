class Recording < ActiveRecord::Base
  include AccessDeterminationHelper

  has_many :recording_performances
  has_many :performances, through: :recording_performances
  has_many :recording_contributor_people
  has_many :people, through: :recording_contributor_people

  belongs_to :atom_feed_read
  belongs_to :avalon_item
  has_one :pod_physical_object, class_name: 'PodPhysicalObject', foreign_key: 'mdpi_barcode', primary_key: 'mdpi_barcode'
  has_one :pod_unit, through: :pod_physical_object

  accepts_nested_attributes_for :recording_performances

  UNITS = ["B-AAAI", "B-AAAMC", "B-AFRIST", "B-ALF", "B-ANTH", "B-ARCHIVES", "B-ASTR", "B-ATHBASKM", "B-ATHBASKW",
           "B-ATHFHOCKEY", "B-ATHFTBL", "B-ATHROWING", "B-ATHSOCCM", "B-ATHSOFTB", "B-ATHTENNM", "B-ATHVIDEO",
           "B-ATHVOLLW", "B-ATM", "B-BCC", "B-BFCA", "B-BUSSPEA", "B-CAC", "B-CDEL", "B-CEDIR", "B-CELCAR", "B-CELTIE",
           "B-CEUS", "B-CHEM", "B-CISAB", "B-CLACS", "B-CMCL", "B-CREOLE", "B-CSHM", "B-CYCLOTRN", "B-EASC", "B-EDUC",
           "B-EPPLEY", "B-FACILITY", "B-FINEARTS", "B-FOLKETHNO", "B-FRANKLIN", "B-GBL", "B-GEOLOGY", "B-GLBTSSSL",
           "B-GLEIM", "B-GLOBAL", "B-HPER", "B-IAS", "B-IAUNRC", "B-IPRC", "B-IUAM", "B-IULMIA", "B-JOURSCHL", "B-KINSEY",
           "B-LACASA", "B-LAW", "B-LIBERIA", "B-LIFESCI", "B-LILLY", "B-LING", "B-MATHERS", "B-MDP", "B-MUSBANDS", "B-MUSIC",
           "B-MUSOPERA", "B-MUSREC", "B-OID", "B-OPTMSCHL", "B-OPTOMTRY", "B-POLISH", "B-PSYCH", "B-RECSPORTS", "B-REEI",
           "B-RTVS", "B-SAGE", "B-SAVAIL", "B-SWAIN", "B-TAI", "B-THTR", "B-UNDRWATR", "B-UNIVCOMM", "B-WELLS", "B-WEST",
           "EA-ARCHIVES", "EA-ATHL", "I-ARCHIVES", "I-DENT", "I-LIBR-SCA", "I-RAYBRAD", "KO-ARCHIVES", "NW-ARCHIVES",
           "SB-ARCHIVES", "SB-PHYS", "SB-ULIB", "SE-ARCHIVES"]

  validates :access_determination, :inclusion => {:in => ACCESS_DECISIONS}
  validates :mdpi_barcode, mdpi_barcode: true





end

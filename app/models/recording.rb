class Recording < ActiveRecord::Base
  has_many :recording_performances
  has_many :performances, through: :recording_performances
  has_many :recording_contributor_people
  has_many :past_access_decisions


  belongs_to :atom_feed_read
  has_one :pod_physical_object, class_name: 'PodPhysicalObject', foreign_key: 'mdpi_barcode', primary_key: 'mdpi_barcode'
  has_one :pod_unit, through: :pod_physical_object


  DEFAULT_ACCESS = "Default IU Access - Not Reviewed"
  IU_ACCESS = "IU Access - Reviewed"
  WORLD_WIDE_ACCESS = "World Wide Access"
  RESTRICTED_ACCESS = "Restricted Access"
  ACCESS_DECISIONS = [DEFAULT_ACCESS, IU_ACCESS, WORLD_WIDE_ACCESS, RESTRICTED_ACCESS]
  ORDERED_ACCESS_DECISIONS = [RESTRICTED_ACCESS, IU_ACCESS, DEFAULT_ACCESS, WORLD_WIDE_ACCESS]
  # default access is the highest rank so that it is omitted from subsequent access requests - any access determination
  # after the default value is considered 'reviewed'
  ACCESS_RANKING = {
      RESTRICTED_ACCESS => 1,
      IU_ACCESS => 2,
      WORLD_WIDE_ACCESS => 3,
      DEFAULT_ACCESS => 4
  }

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

  after_update :record_access_change

  def record_access_change
    PastAccessDecision.new(recording_id: self.id, decision: self.access_determination, changed_by: User.current_username, copyright_librarian: User.copyright_librarian?).save! if access_determination_changed?
  end

  def last_copyright_librarian_decision
    past_access_decisions.where(copyright_librarian: true).order('created_at DESC').limit(1).first
  end

  def allowed_access_determinations
    if User.copyright_librarian?
      ACCESS_DECISIONS
    else
      allowed = []
      max = ACCESS_RANKING[self.access_determination]
      ACCESS_RANKING.each do |key, value|
        puts "Doing it: key: #{key}, value: #{value}, max: #{max}"
        if value <= max
          allowed << key
        end
      end
      allowed
    end
  end

  def self.most_restrictive_access(args)
    actual = nil
    args.each do |a|
      raise "Not a valid Access Decision - #{a}" unless ACCESS_DECISIONS.include? a
      actual = a if actual.nil? || ORDERED_ACCESS_DECISIONS.find_index(a) < ORDERED_ACCESS_DECISIONS.find_index(actual)
    end
    actual
  end


end

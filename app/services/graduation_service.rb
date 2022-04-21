# A service that:
# 1. Checks the repository for works in the `approved` workflow state
# 2. For each of these works, query the registrar data to see if the student has graduated
# 3. If so, call GraduationJob for the given work and the graduation_date returned by registrar data
# @param [String] The path to the data JSON file. Expects location of registrar data to be set in REGISTRAR_DATA_PATH, e.g., in .env.production
# @example How to call this service
#  GraduationService.run
class GraduationService
  attr_reader :status

  def self.run(registrar_data_path = ENV['REGISTRAR_DATA_PATH'])
    new(registrar_data_path).run
  end

  # Load the provided file into a JSON object for processing
  def initialize(registrar_data_path)
    raise "Cannot find registrar data at: #{registrar_data_path || 'no path provided'}" unless File.file?(registrar_data_path)
    Rails.logger.warn("Graduation service: Running graduation service with file #{registrar_data_path}")
    @registrar_data = JSON.parse(File.read(registrar_data_path))
    @registrar_data.default = {}
  end

  # Find all ETDs that have been 'approved' but not yet 'published'
  # Match them to graduation records and check whether a degree has been awarded yet
  def run
    return unless @registrar_data
    approved_etds = graduation_eligible_works
    publishable_etds = lookup_registrar_status(approved_etds)
    publishable_etds.each do |etd|
      GraduationJob.perform_now(etd['id'], etd['degree_awarded_dtsi'])
      Rails.logger.warn "Graduation service:  - Awarded degree for ETD #{etd['id']} as of #{etd['degree_awarded_dtsi']}"
    end
    Rails.logger.warn "Graduation service: Published #{publishable_etds.count} ETDs"
  end

  # Find all Etds in the 'approved' workflow state that are eligible for graduation
  # @return [Array<Hash>] An Array of Hashes representing the ETDs indexed to Solr
  def graduation_eligible_works
    eligible_works = []
    # Use #search_in_batches to avoid timeouts in the case where there are a large number of ETDs
    # that have been approved and are pending graduation (i.e. publication)
    Etd.search_in_batches({ workflow_state_name_ssim: 'approved' }, batch_size: 50) do |batch|
      eligible_works.concat(batch)
    end

    Rails.logger.warn "Graduation service: There are #{eligible_works.count} ETDs approved for graduation"
    eligible_works
  end

  # Check whether the ETD depositors appear in the registrar data,
  # and return their graduation date if present
  # @param [Array<Hash>] candidate_etds list to check depositor PPIDs from
  # @return [Array<Hash>] similar list with graduation_date filled in for graduated students;
  #   omits the ETD record if no corresponding graduation date was found
  def lookup_registrar_status(candidate_etds)
    registrar_matches = []
    candidate_etds.each do |etd_solr_doc|
      ppid   = etd_solr_doc['depositor_ssim']&.first
      school = SCHOOL_MAP[ etd_solr_doc['school_tesim']&.first ]
      degree = DEGREE_MAP[ etd_solr_doc['degree_tesim']&.first ]
      registrar_index = "#{ppid}-#{school}-#{degree}"
      grad_record = @registrar_data[registrar_index]
      etd_solr_doc['degree_awarded_dtsi'] = grad_record['degree status date']
      etd_solr_doc['grad_record'] = grad_record
      registrar_matches << etd_solr_doc if grad_record['degree status date']
      Rails.logger.info "Graduation service:   - ETD #{etd_solr_doc['id']} has registrar index #{registrar_index} with graduation date #{grad_record['degree status date'] || '(nil)'}"
    end
    Rails.logger.warn "Graduation service: There are #{registrar_matches.count} ETDs with recorded graduation dates"
    registrar_matches
  end

  # DEGREE_MAP: Keys = Laevigata degree codes (degree_tesim); Values = corresponding Registrar academic program codes
  # degree codes extracted from registrar_data*.json files:
  # "BA", "BBA", "BS", "CRG", "DM", "DNP", "MA", "MDP", "MDV", "MPH", "MRL", "MRPL", "MS", "MSN", "MSPH", "MT", "MTS", "PHD"
  # academic program codes extracted from registrar_data*.json files:
  # {"BA"=>"LIBAS", "BBA"=>"BBA", "BS"=>"LIBAS", "CRG"=>"CRGGS", "DM"=>"DM", "DNP"=>"DNP", "MA"=>"MA", "MDP"=>"MDP", "MDV"=>"MDV", "MPH"=>"MPH", "MRPL"=>"MRPL", "MS"=>"MS", "MSN"=>"MSN", "MSPH"=>"MSPH", "MT"=>"MT", "MTS"=>"MTS", "PHD"=>"PHD"}
  DEGREE_MAP = {
    "B.A." => "LIBAS",
    "B.B.A." => "BBA",
    "B.S." => "LIBAS",
    "DMin" => "DM",
    "D.N.P." => "DNP",
    "M.A." => "MA",
    "M.Div." => "MDV",
    "M.P.H." => "MPH",
    "M.S." => "MS",
    "M.S.P.H." => "MSPH",
    "M.T.S." => "MTS",
    "Ph.D." => "PHD",
    "Th.D." => "THD"
  }.freeze

  # SCHOOL_MAP: Keys = Laevigata school names (school_tesim); Values = corresponding 'acad career code' value
  # acad career codes extracted from registrar_data*.json files:
  # "GSAS", "UCOL", "THEO", "UBUS", "PUBH", "GNUR"
  SCHOOL_MAP = {
    "Laney Graduate School" => "GSAS",
    "Emory College" => "UCOL",
    "Candler School of Theology" => "THEO",
    "Goizueta Business School" => "UBUS",
    "Rollins School of Public Health" => "PUBH",
    "Woodruff School of Nursing" => "GNUR"
  }.freeze
end

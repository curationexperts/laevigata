# A service that:
# 1. Checks the repository for works in the `approved` workflow state
# 2. For each of these works, query the registrar data to see if the student has graduated
# 3. If so, call GraduationJob for the given work and the graduation_date returned by registrar data
# @param [String] The path to the data JSON file. Expects location of registrar data to be set in REGISTRAR_DATA_PATH, e.g., in .env.production
# @example How to call this service
#  GraduationService.run
class GraduationService
  # Base entry point into the Service
  # @param [String] registrar_data_path - path and file name of registrar data to process - expects JSON formatted data
  def self.run(registrar_data_path = ENV['REGISTRAR_DATA_PATH'])
    new(registrar_data_path).run
  end

  # Load the provided file into a JSON hash for processing
  def initialize(registrar_data_path)
    raise "Cannot find registrar data at: #{registrar_data_path || 'no path provided'}" unless File.file?(registrar_data_path)
    Rails.logger.warn "Graduation service: Running graduation service with file #{registrar_data_path}"
    @registrar_data = JSON.parse(File.read(registrar_data_path))
  end

  # Find all ETDs that have been 'approved' but not yet 'published'
  # Match them to graduation records and check whether a degree has been awarded yet
  def run
    return unless @registrar_data
    approved_etds = graduation_eligible_works
    publishable_etds = confirm_registrar_status(approved_etds)
    publishable_etds.each do |etd|
      Rails.logger.warn "Graduation service:  - Awarding degree for ETD #{etd['id']} effective #{etd['degree_awarded_dtsi']}"
      GraduationJob.perform_now(etd['id'], etd['degree_awarded_dtsi'], etd['grad_record'])
    end
    Rails.logger.warn "GraduationService: Completed - Published #{publishable_etds.count} ETDs"
  end

  # Find all ETDs in the 'approved' workflow state that are eligible for graduation
  # @return [Array<Hash>] An Array of Hashes representing the ETDs indexed to Solr
  def graduation_eligible_works
    eligible_works = []
    # Use #search_in_batches to avoid timeouts in the case where there are a large number of ETDs
    # that have been approved and are pending graduation (i.e. publication)
    Etd.search_in_batches({ workflow_state_name_ssim: 'approved' }, batch_size: 50) do |batch|
      eligible_works.concat(batch)
    end

    Rails.logger.warn "GraduationService: There are #{eligible_works.count} ETDs approved for graduation"
    eligible_works
  end

  # Check whether any registrar record matches the ETD data,
  # and return their graduation date if present
  # @param [Array<Hash>] candidate_etds - list to match against registrar data
  # @return [Array<Hash>] similar list with graduation_date filled in for graduated students;
  #   omits the ETD record if no corresponding graduation date was found
  def confirm_registrar_status(candidate_etds)
    registrar_matches = []
    candidate_etds.each do |etd_solr_doc|
      grad_date, grad_record = find_registrar_match(etd_solr_doc)
      etd_solr_doc['degree_awarded_dtsi'] = grad_date
      etd_solr_doc['grad_record'] = filter_address(grad_record)
      registrar_matches << etd_solr_doc if grad_date
    end
    Rails.logger.warn "GraduationService: There are #{registrar_matches.count} approved ETDs with recorded graduation dates"
    registrar_matches
  end

  # Search registrar data for a student record with matching PPID, School, and Degree
  # @param [Hash] etd_solr_doc - Solr doc hash for corresponding ETD record
  # @return Array[Time, Hash{String->String}]
  #     grad_date - ISO formatted date if the student has graduated;
  #     grad_record - the corresponding registrar record
  def find_registrar_match(etd_solr_doc)
    ppid = etd_solr_doc['depositor_ssim']&.first
    school = SCHOOL_MAP[etd_solr_doc['school_tesim']&.first]
    degree = DEGREE_MAP[etd_solr_doc['degree_tesim']&.first]
    registrar_index = "#{ppid}-#{school}-#{degree}"
    dual_major_index = "#{ppid}-UBUS-BBA" if school == 'UCOL' && degree == 'BBA'

    grad_record = @registrar_data[registrar_index] || @registrar_data[dual_major_index] || { 'degree status descr' => 'Unmatched' }
    grad_date = extract_date(grad_record)
    log_registrar_match(etd_solr_doc, registrar_index, grad_record, grad_date)
    [grad_date, grad_record]
  end

  # Checks a registrar record for a valid graduation date
  # @param [Hash] grad_record - a single record from the registrar data feed
  # @return [Time] - the graduation date (with timezone offset) if the student has graduated
  def extract_date(grad_record)
    return unless grad_record.is_a?(Hash)
    degree_status_date = grad_record['degree status date']
    match = degree_status_date&.match(/\d{4}-\d{2}-\d{2}/)
    match.to_s.to_time(:local) if match
  end

  # Log status data to assist auditing and reporting on this run of the GraduationService
  def log_registrar_match(etd_solr_doc, registrar_index, grad_record, grad_date)
    case grad_record['degree status descr']

    # Exact match found with valid graduation date
    when /Awarded/i
      msg = "awarded\", graduation_date: \"#{grad_date}"

    # No match found in registrar data, look for similar records with matching PPID
    when /Unmatched/i
      ppid = etd_solr_doc['depositor_ssim']&.first
      id_matches = @registrar_data.select { |k, _v| k.match ppid }
      msg = if id_matches.count > 0
              "no match. Other records with matching PPID: " + id_matches.map { |_k, v| "#{v['etd record key']} (#{v['degree status date']})" }.join(', ')
            else
              "PPID not found in registrar data"
            end

    # Match found in registrar data, but no graduation date present
    else
      msg = "graduation pending"
    end

    Rails.logger.warn "GraduationService:  - ETD: #{etd_solr_doc['id']}, registrar_key: #{registrar_index}, msg: \"#{msg}\""
  end

  # Return a filtered version of the grad record that only includes data required for potential Proquest submission
  def filter_address(grad_record)
    grad_record.slice('home address 1', 'home address 2', 'home address 3', 'home address city', 'home address state', 'home address postal code', 'home address country code')
  end

  # DEGREE_MAP: Keys = Laevigata degree codes (degree_tesim); Values = corresponding Registrar academic program codes
  # degree codes extracted from live data which currently include both id and term values from https://github.com/curationexperts/laevigata/blob/main/config/authorities/degree.yml#L29
  # "BA", "BBA", "BS", "CRG", "DM", "DNP", "MA", "MDP", "MDV", "MPH", "MRL", "MRPL", "MS", "MSN", "MSPH", "MT", "MTS", "PHD"
  # academic program codes extracted from registrar_data*.json files:
  #   {"BA"=>"LIBAS", "BBA"=>"BBA", "BS"=>"LIBAS", "CRG"=>"CRGGS", "DM"=>"DM", "DNP"=>"DNP", "MA"=>"MA", "MDP"=>"MDP",
  #    "MDV"=>"MDV", "MPH"=>"MPH", "MRPL"=>"MRPL", "MS"=>"MS", "MSN"=>"MSN", "MSPH"=>"MSPH", "MT"=>"MT", "MTS"=>"MTS", "PHD"=>"PHD"}
  DEGREE_MAP = {
    "B.A." => "LIBAS", "BA" => "LIBAS",
    "B.B.A." => "BBA", "BBA" => "BBA",
    "B.S." => "LIBAS", "BS" => "LIBAS",
    "DMin" => "DM",    "D.Min" => "DM",
    "D.N.P." => "DNP", "DNP" => "DNP",
    "M.A." => "MA",    "MA" => "MA",
    "M.Div." => "MDV", "MDiv" => "MDV",
    "M.P.H." => "MPH", "MPH" => "MPH",
    "M.S." => "MS",    "MS" => "MS",
    "M.S.P.H." => "MSPH", "MSPH" => "MSPH",
    "M.T.S." => "MTS", "MTS" => "MTS",
    "Ph.D." => "PHD",  "PhD" => "PHD",
    "Th.D." => "THD",  "ThD" => "THD"
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

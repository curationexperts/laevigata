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
    @status = OpenStruct.new(overall: 'Not run')
  end

  # Find all ETDs that have been 'approved' but not yet 'published'
  # Match them to graduation records and check whether a degree has been awarded yet
  def run
    return unless @registrar_data
    @status.overall = 'Running'
    approved_etds = graduation_eligible_works
    publishable_etds = lookup_registrar_status(approved_etds)
    publishable_etds.each do |etd|
      GraduationJob.perform_now(etd['id'], etd['degree_awarded_dtsi'])
      Rails.logger.warn "Graduation service: Awarded degree for ETD #{etd['id']} as of #{etd['degree_awarded_dtsi']}"
    end
    @status.degree_eligible_etds = approved_etds.count
    @status.newly_published_etds = publishable_etds.count
    @status.overall = 'Completed'
    Rails.logger.warn "Graduation service: published #{@status.newly_published_etds} ETDs"
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

    Rails.logger.warn "Graduation service: There are #{eligible_works.count} ETDs eligible for graduation"
    eligible_works
  end

  # Check whether the ETD depositors appear in the registrar data,
  # and return their graduation date if present
  # @param [Array<Hash>] candidate_etds list to check depositor PPIDs from
  # @return [Array<Hash>] similar list with graduation_date filled in for graduated students;
  #   omits the ETD record if no corresponding graduation record was found
  def lookup_registrar_status(candidate_etds)
    # Generate the list of ppids for ETDs that are approved but not published
    degree_candidates = candidate_etds.map { |doc| doc['depositor_ssim'].first }

    # Create a hash of registrar data indexed by ppid and degree code
    # Only include data for students from the candidate list (5~40 records vs. 10K records in the full data file)
    # Assumes that each degree code can occur a maximum of once per student ppid
    #
    # example
    # {"P0000002"=>{"B.S."=>"2017-05-18", "M.S."=>"2019-11-14"}, "P0000004"=>{"M.Div."=>"2018-01-12"}}
    candidate_index = {}
    @registrar_data.each do |_k, grad_record|
      ppid = grad_record['public person id']
      degree_code = DEGREE_MAP[grad_record['degree code']]
      graduation_date = grad_record['degree status date']
      if (degree_candidates.include? ppid) && degree_code && graduation_date
        candidate_index[ppid] ||= {}
        candidate_index[ppid][degree_code] = graduation_date
      end
    end
    # Provide a default so we can pass unmatched ppids and degrees without errors
    candidate_index.default = {}

    # Return only ETD records that have matching registrar records
    # & update the record with the date if it exists
    candidate_etds.select do |doc|
      ppid = doc['depositor_ssim']&.first
      degree = doc['degree_tesim']&.first
      doc['degree_awarded_dtsi'] = candidate_index[ppid][degree]
      Rails.logger.debug "Graduation service: Matching ETD #{id} to registrar #{ppid}--#{degree} = #{candidate_index[ppid][degree] || 'no date found'}"
    end
  end

  # DEGREE_MAP: Keys = Registrar degree codes; Values = corresponding Laevigata degree codes
  # degree codes extracted from registrar_data*.json files:
  # "BA", "BBA", "BS", "CRG", "DM", "DNP", "MA", "MDP", "MDV", "MPH", "MRL", "MRPL", "MS", "MSN", "MSPH", "MT", "MTS", "PHD"
  DEGREE_MAP = {
    "BA" => "B.A.",
    "BBA" => "B.B.A.",
    "BS" => "B.S.",
    "DM" => "DMin",
    "DNP" => "D.N.P.",
    "MA" => "M.A.",
    "MDV" => "M.Div.",
    "MPH" => "M.P.H.",
    "MS" => "M.S.",
    "MSPH" => "M.S.P.H.",
    "MTS" => "M.T.S.",
    "PHD" => "Ph.D.",
    "THD" => "Th.D."
  }.freeze
end

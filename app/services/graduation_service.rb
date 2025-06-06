# A service that:
# 1. Checks the repository for works in the `approved` workflow state
# 2. For each of these works, query the registrar data to see if the student has graduated
# 3. If so, call GraduationJob for the given work and the graduation_date returned by registrar data
# @param [RegistrarFeed] a RegistarFeed object - expected to have a valid registar graduation_record file attached
# @example How to call this service
#  GraduationService.run
class GraduationService
  attr_reader :graduation_report

  # Base entry point into the Service
  # @param [RegistrarFeed] registrar_feed - object with JSON graduation data data attached
  def self.run(registrar_feed)
    new(registrar_feed).run
  end

  # Parse and validate the graduation data attached to the registrar feed
  def initialize(registrar_feed)
    raise ArgumentError, "invalid feed object: #{registrar_feed.class}" unless registrar_feed.is_a? RegistrarFeed
    Rails.logger.warn "Graduation service: Running graduation service for #{registrar_feed.to_global_id}"
    @registrar_feed = registrar_feed
    @registrar_feed.published_etds = published_etds
    @registrar_data = parse_registrar_file
    @graduation_report = GraduationReport.new
    raise FormatError unless contains_graduation_data
  end

  # Find all ETDs that have been 'approved' but not yet 'published'
  # Match them to graduation records and check whether a degree has been awarded yet
  def run
    approved_etds = graduation_eligible_works
    Rails.logger.warn "GraduationService: There are #{approved_etds.count} ETDs approved for graduation"
    publishable_etds = confirm_registrar_status(approved_etds)
    Rails.logger.warn "GraduationService: There are #{publishable_etds.count} approved ETDs with recorded graduation dates"
    publishable_etds.each do |etd|
      Rails.logger.warn "Graduation service:  - Awarding degree for ETD #{etd['id']} effective #{etd['degree_awarded_dtsi']}"
      GraduationJob.perform_now(etd['id'], etd['degree_awarded_dtsi'], etd['grad_record'])
    end
    Rails.logger.warn "GraduationService: Completed - Published #{publishable_etds.count} ETDs"
    Rails.logger.warn "Results saved to #{@graduation_report.filename}"

    update_registrar_feed(approved_etds, publishable_etds)
  end

  # Read registrar data from CSV or JSON source file
  # responsible for massaging the input file into the same json structure
  # @return [Hash] a hash of registrar keys pointing at the associated student graduation records
  def parse_registrar_file
    grad_records = @registrar_feed.graduation_records
    case grad_records.content_type
    when 'text/csv', 'application/vnd.ms-excel'
      registrar_csv = CSV.parse(grad_records.download, headers: true, header_converters: :downcase, liberal_parsing: true)
      registrar_csv.map { |row| [row['etd record key'], row.to_hash] }.to_h
    when 'application/json'
      JSON.parse(grad_records.download)
    else
      raise ArgumentError, "Unexpectected content type: #{grad_records.content_type.inspect}"
    end
  end

  # Save process stats and the report to the registrar feed
  def update_registrar_feed(approved_etds, publishable_etds)
    @registrar_feed.approved_etds = approved_etds.count
    @registrar_feed.graduated_etds = publishable_etds.count
    @registrar_feed.report.attach(io: File.open(@graduation_report.filename),
                                  filename: @graduation_report.filename.basename,
                                  content_type: 'text/csv')
    @registrar_feed.save!
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
      grad_record = find_registrar_match(etd_solr_doc)
      grad_date = extract_date(grad_record)
      etd_solr_doc['degree_awarded_dtsi'] = grad_date
      etd_solr_doc['grad_record'] = filter_address(grad_record)
      registrar_matches << etd_solr_doc if grad_date
    end

    @graduation_report.export
    Rails.logger.warn "Results saved to #{@graduation_report.filename}"

    registrar_matches
  end

  # Search registrar data for a student record with matching PPID, School, and Degree
  # @param [Hash] etd_solr_doc - Solr doc hash for corresponding ETD record
  # @return Hash{String->String} - the closest matching registrar record
  def find_registrar_match(etd_solr_doc)
    ppid = etd_solr_doc['depositor_ssim']&.first || "no PPID present"
    school = SCHOOL_MAP[etd_solr_doc['school_tesim']&.first] || "unrecognized school"
    program = PROGRAM_MAP[etd_solr_doc['degree_tesim']&.first] || "unrecognized degree"
    registrar_key = "#{ppid}-#{school}-#{program}"
    dual_major_fragment = "#{ppid}-UBUS" # ignore program when checking for dual majors
    school_fragment = "#{ppid}-#{school}" # check for student and school match

    # find potential matches in the registrar data
    exact_match = @registrar_data[registrar_key]
    school_match = @registrar_data.select { |k, _v| k.match school_fragment }.values.last unless exact_match
    dual_major_match = @registrar_data.select { |k, _v| k.match dual_major_fragment }.values.last if school == 'UCOL' && !(exact_match || school_match)

    # use the closest match in order of priority
    grad_record = exact_match || school_match || dual_major_match || { 'degree status descr' => 'Unmatched', 'etd record key' => registrar_key }
    log_registrar_match(etd_solr_doc, registrar_key, grad_record)
    grad_record
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
  def log_registrar_match(etd_solr_doc, registrar_key, grad_record)
    results = { etd_id: etd_solr_doc['id'],
                registrar_key: registrar_key,
                title: etd_solr_doc['title_tesim']&.first }

    case grad_record['degree status descr']
    # Exact match found with valid graduation date
    when /Awarded/i
      actual_key = grad_record['etd record key']
      results[:grad_date] = grad_record['degree status date']
      if registrar_key == actual_key
        results[:status] = :published_exact
      else
        results[:status] = :published_reconciled
        results[:reconciled_key] = actual_key
      end

    # No match found in registrar data, look for similar records with matching PPID
    when /Unmatched/i
      results[:status] = :unmatched

      # list any keys matching PPID for other schools
      ppid = etd_solr_doc['depositor_ssim']&.first
      ppid_matches = @registrar_data.select { |k, _v| k.match ppid }.keys
      results[:similar_keys] = ppid_matches.join(' ') if ppid_matches.count > 0
      results[:submission_name] = etd_solr_doc['creator_tesim']&.first
      results[:shibboleth_name] = User.find_by(ppid: ppid)&.display_name

    # Match found in registrar data, but no graduation date present
    else
      results[:status] = :pending
    end

    Rails.logger.warn "GraduationService:  #{results.to_json}"
    @graduation_report.add(results)
  end

  # Return a filtered version of the grad record that only includes data required for potential Proquest submission
  def filter_address(grad_record)
    grad_record.slice('home address 1', 'home address 2', 'home address 3', 'home address city', 'home address state', 'home address postal code', 'home address country code')
  end

  def published_etds
    # Todo: find a clearer way to get a count of ETDs in the 'published' workflow state
    @published_etds_from_solr ||= Hyrax::Admin::RepositoryObjectPresenter.new.as_json.find { |e| e[:label] == 'Published' }[:value]
  end

  # Scan the registrar data for at least one key value pair with
  # the key 'degree status date' and a value longer than 4 characters.
  # If these keys and values are not present, the file
  # probably does not contain correctly formatted graduation data.
  def contains_graduation_data
    @registrar_data.find { |_k, v| v.fetch('degree status date', '')&.match?(/\d{4}-\d{2}-\d{2}/) }.present?
  end

  # PROGRAM_MAP: Keys = Laevigata degree codes (degree_tesim); Values = corresponding Registrar academic program codes
  # We're using program codes to match instead of degree codes because program codes are always present in registrar data
  # degree codes extracted from live data which currently include both id and term values from https://github.com/curationexperts/laevigata/blob/main/config/authorities/degree.yml#L29
  # "BA", "BBA", "BS", "CRG", "DM", "DNP", "MA", "MDP", "MDV", "MPH", "MRL", "MRPL", "MS", "MSN", "MSPH", "MT", "MTS", "PHD"
  # academic program codes extracted from registrar_data*.json files:
  #   {"BA"=>"LIBAS", "BBA"=>"BBA", "BS"=>"LIBAS", "CRG"=>"CRGGS", "DM"=>"DM", "DNP"=>"DNP", "MA"=>"MA", "MDP"=>"MDP",
  #    "MDV"=>"MDV", "MPH"=>"MPH", "MRPL"=>"MRPL", "MS"=>"MS", "MSN"=>"MSN", "MSPH"=>"MSPH", "MT"=>"MT", "MTS"=>"MTS", "PHD"=>"PHD"}
  PROGRAM_MAP = {
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
    "Nell Hodgson Woodruff School of Nursing" => "GNUR"
  }.freeze
end

class FormatError < RuntimeError
  def initialize(msg = 'file does not appear to contain valid registrar data in JSON format')
    super
  end
end

class GraduationReport
  REPORT_FIELDS = [:status, :etd_id, :registrar_key, :reconciled_key, :grad_date, :similar_keys, :shibboleth_name, :submission_name, :title, :link].freeze
  STATUS_ORDER = [:unmatched, :published_reconciled, :published_exact, :pending].freeze
  STATUS_INDEX = REPORT_FIELDS.index(:status)
  REGISTRAR_KEY_INDEX = REPORT_FIELDS.index(:registrar_key)

  require 'csv'
  include Rails.application.routes.url_helpers

  attr_reader :filename

  def initialize
    @filename = Rails.root.join('log', "graduation-#{Time.current.strftime('%FT%T')}.csv")
    @report_data = []
  end

  def export
    @report = CSV.open(@filename, "w")
    @report << REPORT_FIELDS.map(&:upcase)

    # group records by status and sort within groups by report_key
    STATUS_ORDER.each do |status|
      status_group = @report_data.select { |row| row[STATUS_INDEX] == status }.sort_by { |a, b| report_key(a) <=> report_key(b) }
      @report << blank_row if status_group.count > 0
      status_group.each { |row| @report << row }
    end

    @report.close
  end

  def add(**fields)
    fields[:link] = hyrax_etd_url(fields[:etd_id])
    row = REPORT_FIELDS.map { |field_name| fields[field_name] }
    @report_data << row
  end

  private

  # encapsulate the rules for sorting rows
  def report_key(row)
    ppid, school, program = row[REGISTRAR_KEY_INDEX]&.split('-')
    "#{school}-#{program}-#{ppid}"
  end

  def blank_row
    REPORT_FIELDS.map { |e| nil }
  end
end

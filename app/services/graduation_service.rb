# An automated service that:
# 1. Checks the repository for works in the `approved` workflow state but which have no `degree_awarded` value
# 2. For each of these works, query the registrar data to see if the student has graduated
# 3. If so, call GraduationJob for the given work and the graduation_date returned by registrar data
# @param [String] The path to the data JSON file. Expects location of registrar data to be set in REGISTRAR_DATA_PATH, e.g., in .env.production
# @example How to call this service
#  GraduationService.run
class GraduationService
  def self.run(registrar_data_path = ENV['REGISTRAR_DATA_PATH'])
    Rails.logger.warn("Graduation service: Running graduation service with file #{registrar_data_path}")
    raise "Cannot find registrar data" unless registrar_data_path && File.file?(registrar_data_path)
    Rails.logger.warn("Graduation service: found registrar data")
    GraduationService.load_data(registrar_data_path)
    GraduationService.graduation_eligible_works.each do |work|
      degree_awarded_date = GraduationService.check_degree_status(work)
      if degree_awarded_date
        Rails.logger.warn "Graduation service: Awarding degree for ETD #{work['id']} as of #{degree_awarded_date}"
        GraduationJob.perform_now(work['id'], degree_awarded_date.to_s)
      end
    end
    remove_instance_variable(:@registrar_data)
  end

  # Load the Registrar's data from the JSON file.
  # @param [String] The path to the data JSON file.
  def self.load_data(path_to_data)
    @registrar_data = JSON.parse(File.read(path_to_data))
  end

  # Find all Etds in the 'approved' workflow state that are eligible for graduation
  # @return [Array<SolrDocument>] An Array of SolrDocuments indexed for the matching ETDs
  def self.graduation_eligible_works
    eligible_works = []
    # Use #search_in_batches to avoid timeouts in the case where there are a large number of ETDs
    # that have been approved and are pending graduation (i.e. publication)
    Etd.search_in_batches({ workflow_state_name_ssim: 'approved' }, batch_size: 50) do |batch|
      eligible_works.concat(batch.to_a)
    end

    Rails.logger.warn "Graduation service: There were #{eligible_works.count} ETDs eligible for graduation"
    eligible_works
  end

  # Check the degree status for the given work. If the degree has been awarded, return the relevant date.
  # @param [SolrDocument] work - the SolrDocument indexed for the corresponding ETD
  # @return [Date] the date the degree was awarded, otherwise false
  def self.check_degree_status(work)
    return Time.zone.today.strftime('%Y-%m-%d') if Rails.env.development? || ENV['FAKE_DATA'] # Otherwise it will never find registrar data for our fake users
    # Find all records by this PPID
    records = @registrar_data.select { |_k, v| v['public person id'] == work['depositor_ssim'].first }
    if records.count == 1
      # If one record is found, and it is awarded, return the status date.
      if records.values[0]['degree status descr'] == 'Awarded'
        return Date.strptime(records.values[0]['degree status date'], '%Y-%m-%d')
      end
    elsif records.count.zero?
      # If no records are found, the student hasn't graduated yet.
      Rails.logger.warn "Graduation service: ETD #{work['id']} from depositor #{work['depositor_ssim'].first} is eligible for graduation but has not appeared in registrar graduation data."
    else
      # Multiple records
      status = Set.new(records.map { |_k, v| v['degree status descr'] })
      if status.size == 1 && status.include?('Awarded')
        # If all degrees are awarded, return the most recent date.
        award_dates = records.map { |_k, v| Date.strptime(v['degree status date'], '%Y-%m-%d') }
        return award_dates.max
      elsif status.size != 1
        # Some, but not all degrees are awarded
        record = disambiguate_registrar(work, records)
        unless record.nil?
          # Return the date from the relevant record.
          return Date.strptime(record['degree status date'], '%Y-%m-%d')
        end
      end
    end
    # Degree not awarded, no record found, or too ambiguous to tell. Return nil
    nil
  end

  # If there is more than one record matching the student, find the one that matches the degree code
  # of the etd. If that record has it's degree awarded, graduate the etd.
  def self.disambiguate_registrar(work, records)
    degree_code_matches = records.select { |_key, value| value['degree code'] == work_degree(work['degree_tesim'].first) }
    if degree_code_matches.size == 1 && degree_code_matches.first[1]['degree status descr'] == 'Awarded'
      return degree_code_matches.first[1]
    end
    nil
  end

  def self.work_degree(work_degree)
    # This hash will map degree codes from laevigata to degrees in @registrar_data
    degrees = { "Th.D." => "THD", "Ph.D." => "PHD", "DMin" => "DM", "D.N.P." => "DNP",
                "M.A." => "MA", "M.S." => "MS", "M.Div." => "MDV", "M.T.S." => "MTS",
                "M.P.H." => "MPH", "M.S.P.H." => "MSPH", "B.A." => "BA", "B.S." => "BS",
                "B.B.A." => "BBA" }
    # work_degree now has the work's degree as it is represented in @registrar_data
    work_degree = degrees[work_degree]
    # Return degree as it is in @registrar_data
    work_degree
  end
end

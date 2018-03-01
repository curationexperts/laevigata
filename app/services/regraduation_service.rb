# A manual job meant for (hopefully) one time use.
# Does everything that graduation job does but does it even if the person has a graduation date recorded already.
# This is so we can re-process all the graudates in our first graduation run who didn't
# have proquest packages sent, or have their workflow updated correctly
# 1. Checks the repository for works in the `approved` workflow state but which have no `degree_awarded` value
# 2. For each of these works, query the registrar data to see if the student has graduated
# 3. If so, call GraduationJob for the given work and the graduation_date returned by registrar data
# @param [String] The path to the data JSON file. Expects location of registrar data to be set in REGISTRAR_DATA_PATH, e.g., in .env.production
# @example How to call this service
#  RegraduationService.run
class RegraduationService
  def self.run(registrar_data_path = ENV['REGISTRAR_DATA_PATH'])
    raise "Cannot find registrar data" unless registrar_data_path && File.file?(registrar_data_path)
    Rails.logger.info("Running graduation service with file #{registrar_data_path}")
    GraduationService.load_data(registrar_data_path)
    GraduationService.graduation_eligible_works.each do |work|
      degree_awarded_date = GraduationService.check_degree_status(work)
      GraduationJob.perform_later(work.id, degree_awarded_date.to_s) if degree_awarded_date
    end
  end

  # Load the Registrar's data from the JSON file.
  # @param [String] The path to the data JSON file.
  def self.load_data(path_to_data)
    @registrar_data = JSON.parse(File.read(path_to_data))
  end

  # Find all Etds in the 'approved' workflow state that have a degree awarded in 2018
  # @return [Array<Etd>] An Array of ETD objects
  def self.graduation_eligible_works
    eligible_works = []
    problem_works = []
    no_degree_yet = Etd.where(degree_awarded: "2018-*").to_a
    no_degree_yet.each do |etd|
      begin
        eligible_works << etd if etd.to_sipity_entity.workflow_state_name == 'approved'
      rescue
        problem_works << etd.id
      end
    end
    Rails.logger.error "Could not query workflow status for these works: #{problem_works.inspect}"
    eligible_works
  end

  # Check the degree status for the given work. If the degree has been awarded, return the relevant date.
  # @param [Etd] work
  # @return [Date] the date the degree was awarded, otherwise false
  def self.check_degree_status(work)
    return Time.zone.today.strftime('%Y-%m-%d') if Rails.env.development? || ENV['FAKE_DATA'] # Otherwise it will never find registrar data for our fake users
    # Find all records by this PPID
    records = @registrar_data.select { |_k, v| v['public person id'] == work.depositor }
    if records.count == 1
      # If one record is found, and it is awarded, return the status date.
      if records.values[0]['degree status descr'] == 'Awarded'
        return Date.strptime(records.values[0]['degree status date'], '%Y-%m-%d')
      end
    elsif records.count.zero?
      # If no records are found, log an error.
      Rails.logger.error "Could not find a Registrar record for person #{work.depositor} from ETD #{work.id}"
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
    # Degree not awarded, no record found, or too ambiguous to tell. Return false
    false
  end

  def self.disambiguate_registrar(_work, _records)
    # TODO: Attempt to disambiguate Registrar records
  end
end

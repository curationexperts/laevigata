# An automated service that:
# 1. Checks the repository for works in the `approved` workflow state but which have no `degree_awarded` value
# 2. For each of these works, query the registrar data to see if the student has graduated
# 3. If so, call GraduationJob for the given work and the graduation_date returned by registrar data
# @example How to call this service
#  GraduationService.check_for_new_graduates
class GraduationService
  def self.check_for_new_graduates
    GraduationService.graduation_eligible_works.each do |work|
      degree_awarded_date = GraduationService.check_degree_status(work)
      GraduationJob.perform_later(work, degree_awarded_date.to_s) if degree_awarded_date
    end
  end

  # Find all Etds in the 'approved' workflow state that do not yet have a degree_awarded value
  # @return [Array<Etd>] An Array of ETD objects
  def self.graduation_eligible_works
    eligible_works = []
    problem_works = []
    no_degree_yet = Etd.where(degree_awarded: nil).to_a
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
  # TODO: Make this actually query the registrar data
  # @param [Etd] work
  # @return [Date] the date the degree was awarded, otherwise nil
  def self.check_degree_status(_work)
    Time.zone.today
  end
end

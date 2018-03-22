# services/graduationdate_service.rb
class GraduationdateService < Hyrax::LaevigataAuthorityService
  def initialize
    super('graduation_dates')
  end
end

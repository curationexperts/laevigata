# services/graduationdate_service.rb
class GraduationdateService < Hyrax::QaSelectService
  def initialize
    super('graduation_dates')
  end
end
